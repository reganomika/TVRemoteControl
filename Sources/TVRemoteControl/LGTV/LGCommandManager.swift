import Foundation
import UIKit

final class LGCommandManager {
    private let connection: LGRemoteControlClientProtocol?
    
    init(connection: LGRemoteControlClientProtocol?) {
        self.connection = connection
    }
    
    func sendCommand(_ command: LGRemoteControlTarget) {
        connection?.makeRequest(command)
    }
    
    func sendKeyCommand(_ key: LGRemoteControlKeyTarget) {
        connection?.makeKeyRequest(key)
    }
}
