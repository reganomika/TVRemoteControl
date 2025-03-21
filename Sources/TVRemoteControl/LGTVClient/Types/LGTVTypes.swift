import Foundation

public enum LGTVPairingType: String, Codable {
    case pin = "PIN"
    case prompt = "PROMPT"
}

public enum LGTVRequestType: String {
    case register
    case request
    case subscribe
    case unsubscribe
    case unknown
}

public enum LGTVResponseType: String {
    case response
    case registered
    case error
    case unknown
}
