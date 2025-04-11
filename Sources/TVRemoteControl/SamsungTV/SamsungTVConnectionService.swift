import Foundation
import Combine

public final class SamsungTVConnectionService: @unchecked Sendable {
    
    public static let shared = SamsungTVConnectionService()
    
    private var tvCommander: SamsungTV?
    
    public var connectedDevice: SamsungTVModel? {
        didSet {
            if connectedDevice != nil {
                isConnected = true
            } else {
                isConnected = false
            }
        }
    }
    
    private var connectionDevice: SamsungTVModel?
    
    @Published public private(set) var isConnected: Bool = false
    
    public var connectionStatusPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }
    
    public func connect(to device: SamsungTVModel, appName: String, commander: SamsungTV?) {
        
        if let commander  {
            
            tvCommander = commander
            
            connectedDevice = device
            
            isConnected = true
                        
        } else {
            
            connectionDevice = device
            
            tvCommander = try? SamsungTV(tv: device, appName: appName)
            tvCommander?.delegate = self
            tvCommander?.connectToTV()
        }
    }
    
    public func disconnect() {
        connectedDevice = nil
        connectionDevice = nil
        
        isConnected = false
        
    }
    
    public func sendCommand(_ command: SamsungTVRemoteCommand.Params.ControlKey) {
        guard connectedDevice != nil else {
            return
        }
        
        tvCommander?.sendRemoteCommand(key: command)
    }
    
    public func sendText(textToSend: String) {
        guard connectedDevice != nil else {
            return
        }
        tvCommander?.sendText(textToSend)
    }
}

extension SamsungTVConnectionService: SamsungTVDelegate {
    
    public func samsungTVDidConnect(_ samsungTV: SamsungTV) {
       
    }
    
    public func samsungTVDidDisconnect(_ samsungTV: SamsungTV) {
        
    }
    
    public func samsungTV(_ samsungTV: SamsungTV, didUpdateAuthState authStatus: SamsungTVAuthStatus) {
        switch authStatus {
        case .allowed:
            
            connectedDevice = connectionDevice
            
            isConnected = true

        case .denied, .none:
            break
        }
    }
    
    public func samsungTV(_ samsungTV: SamsungTV, didWriteRemoteCommand command: SamsungTVRemoteCommand) {
        
    }
    
    public func samsungTV(_ samsungTV: SamsungTV, didEncounterError error: SamsungTVError) {
        
    }
}
