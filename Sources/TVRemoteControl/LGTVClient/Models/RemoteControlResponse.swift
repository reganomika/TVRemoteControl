import Foundation

public struct RemoteControlResponse: Codable {
    public init(type: String? = nil, id: String? = nil, error: String? = nil, payload: RemoteControlResponsePayload? = nil) {
        self.type = type
        self.id = id
        self.error = error
        self.payload = payload
    }
    
    public let type: String?
    public let id: String?
    public let error: String?
    public let payload: RemoteControlResponsePayload?
}
