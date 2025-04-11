import Foundation
import Starscream
import Network

public protocol SamsungTVDelegate: AnyObject {
    func samsungTVDidConnect(_ samsungTV: SamsungTV)
    func samsungTVDidDisconnect(_ samsungTV: SamsungTV)
    func samsungTV(_ samsungTV: SamsungTV, didUpdateAuthState authStatus: SamsungTVAuthStatus)
    func samsungTV(_ samsungTV: SamsungTV, didWriteRemoteCommand command: SamsungTVRemoteCommand)
    func samsungTV(_ samsungTV: SamsungTV, didEncounterError error: SamsungTVError)
}

public class SamsungTV: @unchecked Sendable, WebSocketDelegate {
    public weak var delegate: SamsungTVDelegate?
    private(set) public var tvConfig: SamsungTVConnectionConfiguration
    private(set) public var authStatus = SamsungTVAuthStatus.none
    private(set) public var isConnected = false
    private let webSocketCreator: SamsungTVWebSocketCreator
    private let webSocketHandler = SamsungTVWebSocketHandler()
    private var webSocket: WebSocket?
    private var commandQueue = [SamsungTVRemoteCommand]()

    init(tvConfig: SamsungTVConnectionConfiguration, webSocketCreator: SamsungTVWebSocketCreator) {
        self.tvConfig = tvConfig
        self.webSocketCreator = webSocketCreator
        self.webSocketHandler.delegate = self
    }

    public convenience init(tvId: String? = nil, tvIPAddress: String, appName: String, authToken: SamsungTVAuthToken? = nil) throws {
        guard appName.isValidAppName else {
            throw SamsungTVError.invalidAppNameEntered
        }
        guard tvIPAddress.isValidIPAddress else {
            throw SamsungTVError.invalidIPAddressEntered
        }
        let tvConfig = SamsungTVConnectionConfiguration(
            id: tvId,
            app: appName,
            path: "/api/v2/channels/samsung.remote.control",
            ipAddress: tvIPAddress,
            port: 8002,
            scheme: "wss",
            token: authToken
        )
        self.init(tvConfig: tvConfig, webSocketCreator: SamsungTVWebSocketCreator())
    }

    public convenience init(tv: SamsungTVModel, appName: String, authToken: SamsungTVAuthToken? = nil) throws {
        guard let ipAddress = tv.ipAddress else { throw SamsungTVError.invalidIPAddressEntered }
        try self.init(tvId: tv.id, tvIPAddress: ipAddress, appName: appName, authToken: authToken)
    }

    // MARK: Establish WebSocket Connection

    /// **NOTE**
    /// make sure any value for `certPinner` inputted here doesn't strongly reference `SamsungTV` (will cause a retain cycle if it does)
    public func connectToTV(certPinner: CertificatePinning? = nil) {
        guard !isConnected else {
            handleError(.connectionAlreadyEstablished)
            return
        }
        guard let url = tvConfig.wssURL() else {
            handleError(.urlConstructionFailed)
            return
        }
        webSocket = webSocketCreator.createTVWebSocket(url: url, certPinner: certPinner, delegate: self)
        webSocket?.connect()
    }

    public func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        webSocketHandler.didReceive(event: event, client: client)
    }

    // MARK: Send Remote Control Commands

    public func sendRemoteCommand(key: SamsungTVRemoteCommand.Params.ControlKey) {
        guard isConnected else {
            handleError(.remoteCommandNotConnectedToTV)
            return
        }
        guard authStatus == .allowed else {
            handleError(.remoteCommandAuthenticationStatusNotAllowed)
            return
        }
        sendCommandOverWebSocket(.createClickCommand(key))
    }

    /// Send a text as text field input to the TV. Text will replace existing text in TV textfield.
    public func sendText(_ text: String) {
        guard isConnected else {
            handleError(.remoteCommandNotConnectedToTV)
            return
        }
        guard authStatus == .allowed else {
            handleError(.remoteCommandAuthenticationStatusNotAllowed)
            return
        }
        sendCommandOverWebSocket(.createTextInputCommand(text))
    }

    private func sendCommandOverWebSocket(_ command: SamsungTVRemoteCommand) {
        commandQueue.append(command)
        if commandQueue.count == 1 {
            sendNextQueuedCommandOverWebSocket()
        }
    }

    private func sendNextQueuedCommandOverWebSocket() {
        guard let command = commandQueue.first else {
            return
        }
        guard let commandStr = try? command.asString() else {
            handleError(.commandConversionToStringFailed)
            return
        }
        webSocket?.write(string: commandStr) { [weak self] in
            guard let self else { return }
            self.commandQueue.removeFirst()
            self.delegate?.samsungTV(self, didWriteRemoteCommand: command)
            self.sendNextQueuedCommandOverWebSocket()
        }
    }

    // MARK: Send Keyboard Commands

    public func enterText(_ text: String, on keyboard: TVKeyboardLayout) {
        guard isConnected else {
            handleError(.remoteCommandNotConnectedToTV)
            return
        }
        guard authStatus == .allowed else {
            handleError(.remoteCommandAuthenticationStatusNotAllowed)
            return
        }

        let keys = controlKeys(toEnter: text, on: keyboard)
        keys.forEach(sendRemoteCommand(key:))
    }

    private func controlKeys(toEnter text: String, on keyboard: TVKeyboardLayout) -> [SamsungTVRemoteCommand.Params.ControlKey] {
        guard !text.isEmpty else { return [] } // Check for empty string, otherwise it will crash on line 145

        let chars = Array(text)
        var moves: [SamsungTVRemoteCommand.Params.ControlKey] = [.enter]
        for i in 0..<(chars.count - 1) {
            let currentChar = String(chars[i])
            let nextChar = String(chars[i + 1])
            if let movesToNext = controlKeys(toMoveFrom: currentChar, to: nextChar, on: keyboard) {
                moves.append(contentsOf: movesToNext)
                moves.append(.enter)
            } else {
                delegate?.samsungTV(self, didEncounterError: .keyboardCharNotFound(nextChar))
            }
        }
        return moves
    }

    private func controlKeys(toMoveFrom char1: String, to char2: String, on keyboard: TVKeyboardLayout) -> [SamsungTVRemoteCommand.Params.ControlKey]? {
        guard let (startRow, startCol) = coordinates(of: char1, on: keyboard),
              let (endRow, endCol) = coordinates(of: char2, on: keyboard) else {
            return nil
        }
        let rowDiff = endRow - startRow
        let colDiff = endCol - startCol
        var moves: [SamsungTVRemoteCommand.Params.ControlKey] = []
        if rowDiff > 0 {
            moves += Array(repeating: .down, count: rowDiff)
        } else if rowDiff < 0 {
            moves += Array(repeating: .up, count: abs(rowDiff))
        }
        if colDiff > 0 {
            moves += Array(repeating: .right, count: colDiff)
        } else if colDiff < 0 {
            moves += Array(repeating: .left, count: abs(colDiff))
        }
        return moves
    }

    private func coordinates(of char: String, on keyboard: TVKeyboardLayout) -> (Int, Int)? {
        for (row, rowChars) in keyboard.enumerated() {
            if let colIndex = rowChars.firstIndex(of: char) {
                return (row, colIndex)
            }
        }
        return nil
    }

    // MARK: Disconnect WebSocket Connection

    public func disconnectFromTV() {
        webSocket?.disconnect()
    }

    // MARK: Handler Errors

    private func handleError(_ error: SamsungTVError) {
        delegate?.samsungTV(self, didEncounterError: error)
    }

    // MARK: Wake on LAN

    public static func wakeOnLAN(
        device: SamsungTVWakeOnLANDevice,
        queue: DispatchQueue = .global(),
        completion: @escaping @Sendable (SamsungTVError?) -> Void
    ) {
        let connection = NWConnection(
            host: .init(device.broadcast),
            port: .init(rawValue: device.port)!,
            using: .udp
        )
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                connection.send(
                    content: .magicPacket(from: device),
                    completion: .contentProcessed({
                        connection.cancel()
                        completion($0.flatMap(SamsungTVError.wakeOnLANProcessingError))
                    })
                )
            case .failed(let error):
                completion(.wakeOnLANConnectionError(error))
            default:
                break
            }
        }
        connection.start(queue: queue)
    }
}

// MARK: TVWebSocketHandlerDelegate

extension SamsungTV: SamsungTVWebSocketHandlerDelegate {
    func webSocketDidConnect() {
        isConnected = true
        delegate?.samsungTVDidConnect(self)
    }
    
    func webSocketDidDisconnect() {
        isConnected = false
        authStatus = .none
        webSocket = nil
        delegate?.samsungTVDidDisconnect(self)
    }
    
    func webSocketDidReadAuthStatus(_ authStatus: SamsungTVAuthStatus) {
        self.authStatus = authStatus
        delegate?.samsungTV(self, didUpdateAuthState: authStatus)
    }
    
    func webSocketDidReadAuthToken(_ authToken: SamsungTVAuthToken) {
        tvConfig.token = authToken
    }
    
    func webSocketError(_ error: SamsungTVError) {
        delegate?.samsungTV(self, didEncounterError: error)
    }
}
