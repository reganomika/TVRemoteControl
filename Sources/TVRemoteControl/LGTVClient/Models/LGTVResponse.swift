import Foundation

public struct LGTVResponse: Codable {
    public init(type: String? = nil, id: String? = nil, error: String? = nil, payload: LGTVResponsePayload? = nil) {
        self.type = type
        self.id = id
        self.error = error
        self.payload = payload
    }
    
    public let type: String?
    public let id: String?
    public let error: String?
    public let payload: LGTVResponsePayload?
}
