import Foundation

public struct LGTVResponsePayload: Codable {
    public init(pairingType: LGTVPairingType? = nil, clientKey: String? = nil, volumeStatus: LGTVResponseVolumeStatus? = nil, applications: [LGTVResponseApplication]? = nil, socketPath: String? = nil) {
        self.pairingType = pairingType
        self.clientKey = clientKey
        self.volumeStatus = volumeStatus
        self.applications = applications
        self.socketPath = socketPath
    }
    
    public let pairingType: LGTVPairingType?
    public let clientKey: String?
    public let volumeStatus: LGTVResponseVolumeStatus?
    public let applications: [LGTVResponseApplication]?
    public let socketPath: String?
    
    public enum CodingKeys: String, CodingKey {
        case pairingType
        case clientKey = "client-key"
        case volumeStatus
        case applications = "apps"
        case socketPath
    }
}

public struct LGTVResponseVolumeStatus: Codable {
    public init(muteStatus: Bool? = nil) {
        self.muteStatus = muteStatus
    }
    
    public let muteStatus: Bool?
}
