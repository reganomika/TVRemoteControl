import Foundation

public struct LGRemoteControlResponsePayload: Codable {
    public init(pairingType: LGRemoteControlPairingType? = nil, clientKey: String? = nil, volumeStatus: LGRemoteControlResponseVolumeStatus? = nil, applications: [LGRemoteControlResponseApplication]? = nil, socketPath: String? = nil) {
        self.pairingType = pairingType
        self.clientKey = clientKey
        self.volumeStatus = volumeStatus
        self.applications = applications
        self.socketPath = socketPath
    }
    
    public let pairingType: LGRemoteControlPairingType?
    public let clientKey: String?
    public let volumeStatus: LGRemoteControlResponseVolumeStatus?
    public let applications: [LGRemoteControlResponseApplication]?
    public let socketPath: String?
    
    public enum CodingKeys: String, CodingKey {
        case pairingType
        case clientKey = "client-key"
        case volumeStatus
        case applications = "apps"
        case socketPath
    }
}

public struct LGRemoteControlResponseVolumeStatus: Codable {
    public init(muteStatus: Bool? = nil) {
        self.muteStatus = muteStatus
    }
    
    public let muteStatus: Bool?
}
