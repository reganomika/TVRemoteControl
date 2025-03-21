import Foundation

public struct RemoteControlRequest: Codable {
    public var type: String
    public var id: String?
    public var uri: String?
    public var payload: RemoteControlRequestPayload?
    
    public init(
        type: RemoteControlRequestType,
        id: String? = nil,
        uri: String? = nil,
        payload: RemoteControlRequestPayload? = nil
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
