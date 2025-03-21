import Foundation

public enum LGTVTarget {

    case register(pairingType: LGTVPairingType = .prompt, clientKey: String? = nil)

    case setPin(_ pin: String)

    case volumeUp

    case volumeDown

    case getVolume(subscribe: Bool? = nil)

    case setVolume(_ level: Int)

    case setMute(_ mute: Bool)

    case screenOff

    case screenOn

    case turnOff

    case listApps

    case launchApp(appId: String, contentId: String? = nil, params: String? = nil)

    case closeApp(appId: String, sessionId: String? = nil)

    case sendEnterKey
    
    case getPointerInputSocket

    case channelUp

    case channelDown
    
    case listSources

    case setSource(_ inputId: String)
}

public protocol LGTVKeyTargetProtocol {
    var name: String { get }
    var request: Data? { get }
}

public protocol LGTVTargetProtocol {
    var uri: String? { get }
    var request: LGTVRequest { get }
}

public enum LGTVKeyTarget: LGTVKeyTargetProtocol {

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

extension LGTVTarget: LGTVTargetProtocol {
    public var uri: String? {
        switch self {
        case .setPin:
            return "ssap://pairing/setPin"
        case .volumeUp:
            return "ssap://audio/volumeUp"
        case .volumeDown:
            return "ssap://audio/volumeDown"
        case .getVolume:
            return "ssap://audio/getVolume"
        case .setVolume:
            return "ssap://audio/setVolume"
        case .setMute:
            return "ssap://audio/setMute"
        case .screenOff:
            return "ssap://com.webos.service.tvpower/power/turnOffScreen"
        case .screenOn:
            return "ssap://com.webos.service.tvpower/power/turnOnScreen"
        case .getPointerInputSocket:
              return "ssap://com.webos.service.networkinput/getPointerInputSocket"
        case .turnOff:
            return "ssap://system/turnOff"
        case .listApps:
            return "ssap://com.webos.applicationManager/listApps"
        case .launchApp:
            return "ssap://system.launcher/launch"
        case .closeApp:
            return "ssap://system.launcher/close"
        case .sendEnterKey:
            return "ssap://com.webos.service.ime/sendEnterKey"
        case .channelUp:
            return "ssap://tv/channelUp"
        case .channelDown:
            return "ssap://tv/channelDown"
        case .listSources:
            return "ssap://tv/getExternalInputList"
        case .setSource:
            return "ssap://tv/switchInput"
        default:
            return nil
        }
    }

    public var request: LGTVRequest {
        switch self {
        case .register(let pairingType, let clientKey):
            let payload = LGTVRequestPayload(
                forcePairing: false,
                manifest: LGTVRequestManifest(),
                pairingType: pairingType.rawValue,
                clientKey: clientKey
            )
            return .init(type: .register, payload: payload)
        case .setPin(let pin):
            let payload = LGTVRequestPayload(pin: pin)
            return .init(type: .request, uri: uri, payload: payload)
        case
            .getVolume(let subscribe):
            if let subscribe {
                return .init(type: subscribe ? .subscribe : .unsubscribe, uri: uri)
            }
            return .init(type: .request, uri: uri)
        case .setVolume(let volume):
            let payload = LGTVRequestPayload(volume: volume)
            return .init(type: .request, uri: uri, payload: payload)
        case .setMute(let mute):
            let payload = LGTVRequestPayload(mute: mute)
            return .init(type: .request, uri: uri, payload: payload)
        case .screenOn, .screenOff:
            let payload = LGTVRequestPayload(standbyMode: "active")
            return .init(type: .request, uri: uri, payload: payload)
        case .launchApp(let appId, let contentId, let params):
            let payload = LGTVRequestPayload(id: appId, contentId: contentId, params: params)
            return .init(type: .request, uri: uri, payload: payload)
        case .closeApp(let appId, let sessionId):
            let payload = LGTVRequestPayload(id: appId, sessionId: sessionId)
            return .init(type: .request, uri: uri, payload: payload)
        case .setSource(let inputId):
            let payload = LGTVRequestPayload(inputId: inputId)
            return .init(type: .request, uri: uri, payload: payload)
        default:
            return .init(type: .request, uri: uri)
        }
    }
}

public extension LGTVKeyTarget {
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
