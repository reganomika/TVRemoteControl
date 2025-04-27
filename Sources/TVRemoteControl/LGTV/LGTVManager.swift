import Foundation
import Combine

public enum LGRequests {
    public static let apps = "listAppsRequest"
    public static let volume = "volumeSubscription"
}

public struct LGTVModel: Codable, Hashable {
    public init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    public let name: String
    public let address: String
}

open class LGTVManager {
    @MainActor public static let shared = LGTVManager()
    private let connectionManager = LGConnectionManager()
    private var commandManager: LGCommandManager?
    private let responseHandler = LGResponseHandler()
    
    // MARK: - Public Publishers
    @Published public private(set) var isMuted = false
    @Published public private(set) var availableApps: [LGRemoteControlResponseApplication] = []
    @Published public private(set) var isConnected = false
    @Published public private(set) var clientKey: String? = nil
    
    private var currentDevice: LGTVModel?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    open func connectToDevice(_ device: LGTVModel, clientKey: String) {
        currentDevice = device
        connectionManager.delegate = self
        connectionManager.connect(to: device, clientKey: clientKey)
    }
    
    open func sendCommand(_ command: LGRemoteControlTarget) {
        commandManager?.sendCommand(command)
    }
    
    open func sendKeyCommand(_ key: LGRemoteControlKeyTarget) {
        commandManager?.sendKeyCommand(key)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        responseHandler.onVolumeChange = { [weak self] isMuted in
            self?.isMuted = isMuted
        }
        
        responseHandler.onAppsListReceived = { [weak self] apps in
            self?.availableApps = apps
        }
    }
}

// MARK: - LGConnectionManagerDelegate
extension LGTVManager: LGConnectionManagerDelegate {
    public func didRegister(with clientKey: String) {
        isConnected = true
        self.clientKey = clientKey
        
        if let connection = connectionManager.connection {
            commandManager = LGCommandManager(connection: connection)
            
            connection.makeRequest(.listApps, id: LGRequests.apps)
            connection.makeRequest(.sound(true), id: LGRequests.volume)
        }
    }
    
    public func didDisconnect() {
        isConnected = false
    }
    
    public func didEncounterError() {
        isConnected = false
    }
    
    public func didReceive(_ response: LGRemoteControlResponse) {
        responseHandler.handleResponse(response)
    }
}
