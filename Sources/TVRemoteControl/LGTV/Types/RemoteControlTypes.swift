import Foundation

public enum LGRemoteControlPairingType: String, Codable {
    case pin = "PIN"
    case prompt = "PROMPT"
}

public enum LGRemoteControlRequestType: String {
    case register
    case request
    case subscribe
    case unsubscribe
    case unknown
}

public enum LGRemoteControlResponseType: String {
    case response
    case registered
    case error
    case unknown
}
