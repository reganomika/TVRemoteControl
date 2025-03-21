import Foundation

public protocol RemoteControlClientProtocol {
    func startConnection()

    @discardableResult func makeRequest(_ target: RemoteControlTarget, id: String) -> String?

    func makeKeyRequest(_ key: RemoteControlKeyTarget)
}

public extension RemoteControlClientProtocol {
    @discardableResult func makeRequest(
        _ target: RemoteControlTarget,
        id: String = UUID().uuidString.lowercased()
    ) -> String? {
        makeRequest(target, id: id)
    }
}
