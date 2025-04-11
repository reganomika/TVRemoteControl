import Foundation
import Starscream

protocol SamsungTVWebSocketHandlerDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect()
    func webSocketDidReadAuthStatus(_ authStatus: SamsungTVAuthStatus)
    func webSocketDidReadAuthToken(_ authToken: SamsungTVAuthToken)
    func webSocketError(_ error: SamsungTVError)
}

class SamsungTVWebSocketHandler {
    private let decoder = JSONDecoder()
    weak var delegate: SamsungTVWebSocketHandlerDelegate?

    // MARK: Interact with WebSocket

    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected:
            delegate?.webSocketDidConnect()
        case .cancelled, .disconnected:
            delegate?.webSocketDidDisconnect()
        case .text(let text):
            handleWebSocketText(text)
        case .binary(let data):
            webSocketDidReadPacket(data)
        case .error(let error):
            delegate?.webSocketError(.webSocketError(error))
        default:
            break
        }
    }

    private func handleWebSocketText(_ text: String) {
        if let packetData = text.asData {
            webSocketDidReadPacket(packetData)
        } else {
            delegate?.webSocketError(.packetDataParsingFailed)
        }
    }

    private func webSocketDidReadPacket(_ packet: Data) {
        if let authResponse = parseAuthResponse(from: packet) {
            handleAuthResponse(authResponse)
        } else {
            delegate?.webSocketError(.packetDataParsingFailed)
        }
    }

    // MARK: Receive Auth

    private func parseAuthResponse(from packet: Data) -> SamsungTVAuthResponse? {
        try? decoder.decode(SamsungTVAuthResponse.self, from: packet)
    }

    private func handleAuthResponse(_ response: SamsungTVAuthResponse) {
        switch response.event {
        case .connect:
            parseTokenFromAuthResponse(response)
            delegate?.webSocketDidReadAuthStatus(.allowed)
        case .unauthorized:
            delegate?.webSocketDidReadAuthStatus(.denied)
        case .timeout:
            delegate?.webSocketDidReadAuthStatus(.none)
        default:
            delegate?.webSocketError(.authResponseUnexpectedChannelEvent(response))
        }
    }

    private func parseTokenFromAuthResponse(_ response: SamsungTVAuthResponse) {
        if let newToken = response.data?.token {
            delegate?.webSocketDidReadAuthToken(newToken)
        } else if let refreshedToken = response.data?.clients.first?.attributes.token {
            delegate?.webSocketDidReadAuthToken(refreshedToken)
        } else {
            delegate?.webSocketError(.noTokenInAuthResponse(response))
        }
    }
}
