import Foundation

public protocol LGTVClientProtocol {
    func connect()

    @discardableResult func send(_ target: LGTVTarget, id: String) -> String?

    func sendKey(_ key: LGTVKeyTarget)
}

public extension LGTVClientProtocol {
    @discardableResult func send(
        _ target: LGTVTarget,
        id: String = UUID().uuidString.lowercased()
    ) -> String? {
        send(target, id: id)
    }
}
