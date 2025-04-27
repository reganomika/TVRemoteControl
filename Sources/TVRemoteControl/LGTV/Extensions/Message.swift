import Foundation

extension URLSessionWebSocketTask.Message {
    func decode() -> LGRemoteControlResponse? {
        switch self {
        case .string(let string):
            return try? string.decode()
        case .data:
            return nil
        @unknown default:
            return nil
        }
    }
}
