import Foundation

public struct LGTVRequest: Codable {
    public var type: String
    public var id: String?
    public var uri: String?
    public var payload: LGTVRequestPayload?
    
    public init(
        type: LGTVRequestType,
        id: String? = nil,
        uri: String? = nil,
        payload: LGTVRequestPayload? = nil
    ) {
        self.type = type.rawValue
        self.id = id
        self.uri = uri
        self.payload = payload
    }
    
    public func jsonWithId(_ id: String) -> String? {
        var copy = self
        copy.id = id
        do {
            return try copy.encode()
        } catch {
            print("Error encoding JSON: \(error)")
        }
        return nil
    }
}
