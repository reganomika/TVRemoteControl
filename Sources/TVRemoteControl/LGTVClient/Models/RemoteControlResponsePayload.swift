import Foundation

public struct RemoteControlResponsePayload: Codable {
    public init(pairingType: RemoteControlPairingType? = nil, clientKey: String? = nil, volumeStatus: RemoteControlResponseVolumeStatus? = nil, applications: [RemoteControlResponseApplication]? = nil, socketPath: String? = nil) {
        self.pairingType = pairingType
        self.clientKey = clientKey
        self.volumeStatus = volumeStatus
        self.applications = applications
        self.socketPath = socketPath
    }
    
    public let pairingType: RemoteControlPairingType?
    public let clientKey: String?
    public let volumeStatus: RemoteControlResponseVolumeStatus?
    public let applications: [RemoteControlResponseApplication]?
    public let socketPath: String?
    
    public enum CodingKeys: String, CodingKey {
        case pairingType
        case clientKey = "client-key"
        case volumeStatus
        case applications = "apps"
        case socketPath
    }
}

public struct RemoteControlResponseVolumeStatus: Codable {
    public init(muteStatus: Bool? = nil) {
        self.muteStatus = muteStatus
    }
    
    public let muteStatus: Bool?
}
