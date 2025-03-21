import Foundation

public enum RemoteControlTarget {

    case registration(pairingType: RemoteControlPairingType = .prompt, key: String? = nil)

    case pin(_ pin: String)

    case soundValuePlus

    case soundValueMinus

    case sound(_ subscribe: Bool? = nil)

    case updateSound(_ level: Int)

    case mute(_ mute: Bool)

    case power

    case listApps

    case launchApp(appId: String, contentId: String? = nil, params: String? = nil)

    case closeApp(appId: String, sessionId: String? = nil)

    case ok
    
    case getPointerInputSocket

    case channelPlus

    case channelMinus
}

public protocol RemoteControlKeyTargetProtocol {
    var name: String { get }
    var request: Data? { get }
}

public protocol RemoteControlTargetProtocol {
    var uri: String? { get }
    var request: RemoteControlRequest { get }
}

public enum RemoteControlKeyTarget: RemoteControlKeyTargetProtocol {

    case move(dx: Int, dy: Int, down: Int = 0)
    
    case click
    
    case scroll(dx: Int, dy: Int)
    
    case left
    
    case right
    
    case up
    
    case down
    
    case home
    
    case back
        
    case enter
            
    case exit
    
    case mute
    
    case volumeUp
    
    case volumeDown
    
    case channelUp
    
    case channelDown
}

extension RemoteControlTarget: RemoteControlTargetProtocol {
    public var uri: String? {
        switch self {
        case .pin:
            return "ssap://pairing/setPin"
        case .soundValuePlus:
            return "ssap://audio/volumeUp"
        case .soundValueMinus:
            return "ssap://audio/volumeDown"
        case .sound:
            return "ssap://audio/getVolume"
        case .updateSound:
            return "ssap://audio/setVolume"
        case .mute:
            return "ssap://audio/setMute"
        case .getPointerInputSocket:
              return "ssap://com.webos.service.networkinput/getPointerInputSocket"
        case .power:
            return "ssap://system/turnOff"
        case .listApps:
            return "ssap://com.webos.applicationManager/listApps"
        case .launchApp:
            return "ssap://system.launcher/launch"
        case .closeApp:
            return "ssap://system.launcher/close"
        case .ok:
            return "ssap://com.webos.service.ime/sendEnterKey"
        case .channelPlus:
            return "ssap://tv/channelUp"
        case .channelMinus:
            return "ssap://tv/channelDown"
        default:
            return nil
        }
    }

    public var request: RemoteControlRequest {
        switch self {
        case .registration(let pairingType, let clientKey):
            let payload = RemoteControlRequestPayload(
                forcePairing: false,
                manifest: RemoteControlRequestManifest(),
                pairingType: pairingType.rawValue,
                clientKey: clientKey
            )
            return .init(type: .register, payload: payload)
        case .pin(let pin):
            let payload = RemoteControlRequestPayload(pin: pin)
            return .init(type: .request, uri: uri, payload: payload)
        case .sound(let subscribe):
            if let subscribe {
                return .init(type: subscribe ? .subscribe : .unsubscribe, uri: uri)
            }
            return .init(type: .request, uri: uri)
        case .updateSound(let volume):
            let payload = RemoteControlRequestPayload(volume: volume)
            return .init(type: .request, uri: uri, payload: payload)
        case .mute(let mute):
            let payload = RemoteControlRequestPayload(mute: mute)
            return .init(type: .request, uri: uri, payload: payload)
        case .launchApp(let appId, let contentId, let params):
            let payload = RemoteControlRequestPayload(id: appId, contentId: contentId, params: params)
            return .init(type: .request, uri: uri, payload: payload)
        case .closeApp(let appId, let sessionId):
            let payload = RemoteControlRequestPayload(id: appId, sessionId: sessionId)
            return .init(type: .request, uri: uri, payload: payload)
        default:
            return .init(type: .request, uri: uri)
        }
    }
}

public extension RemoteControlKeyTarget {
    var name: String {
        return String(describing: self).uppercased()
    }
    
    var request: Data? {
        switch self {
        case .move(let dx, let dy, let down):
            return "type:move\ndx:\(dx)\ndy:\(dy)\ndown:\(down)\n\n".data(using: .utf8)
        case .click:
            return "type:click\n\n".data(using: .utf8)
        case .scroll(let dx, let dy):
            return "type:scroll\ndx:\(dx)\ndy:\(dy)\n\n".data(using: .utf8)
        default:
            return "type:button\nname:\(name)\n\n".data(using: .utf8)
        }
    }
}
