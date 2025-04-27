import Foundation

public struct LGRemoteControlRequest: Codable {
    public var type: String
    public var id: String?
    public var uri: String?
    public var payload: LGRemoteControlRequestPayload?
    
    public init(
        type: LGRemoteControlRequestType,
        id: String? = nil,
        uri: String? = nil,
        payload: LGRemoteControlRequestPayload? = nil
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
