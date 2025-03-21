import Foundation

public enum RemoteControlPairingType: String, Codable {
    case pin = "PIN"
    case prompt = "PROMPT"
}

public enum RemoteControlRequestType: String {
    case register
    case request
    case subscribe
    case unsubscribe
    case unknown
}

public enum RemoteControlResponseType: String {
    case response
    case registered
    case error
    case unknown
}
