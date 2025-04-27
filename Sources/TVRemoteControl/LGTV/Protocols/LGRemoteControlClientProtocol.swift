import Foundation

public protocol LGRemoteControlClientProtocol {
    func startConnection()

    @discardableResult func makeRequest(_ target: LGRemoteControlTarget, id: String) -> String?

    func makeKeyRequest(_ key: LGRemoteControlKeyTarget)
}

public extension LGRemoteControlClientProtocol {
    @discardableResult func makeRequest(
        _ target: LGRemoteControlTarget,
        id: String = UUID().uuidString.lowercased()
    ) -> String? {
        makeRequest(target, id: id)
    }
}
