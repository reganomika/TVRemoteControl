import Foundation

protocol LGConnectionManagerDelegate: AnyObject {
    func didRegister(with clientKey: String)
    func didDisconnect()
    func didEncounterError()
    func didReceive(_ response: LGRemoteControlResponse)
}

final class LGConnectionManager {
    weak var delegate: LGConnectionManagerDelegate?
    var connection: LGRemoteControlClientProtocol?
    
    func connect(to device: LGTVModel, clientKey: String) {
        guard let url = URL(string: "wss://\(device.address):3001") else { return }
        connection = LGRemoteControlClient(url: url, delegate: self)
        connection?.startConnection()
        connection?.makeRequest(.registration(key: clientKey))
    }
}

extension LGConnectionManager: LGRemoteControlClientDelegate {
    func didReceive(jsonResponse: String) {}
    
    func didRegister(with clientKey: String) {
        delegate?.didRegister(with: clientKey)
    }
    
    func didConnect() {}
    
    func didDisconnect() {
        delegate?.didDisconnect()
    }
    
    func didReceiveNetworkError(_ error: Error?) {
        delegate?.didEncounterError()
    }
    
    func didReceive(_ result: Result<LGRemoteControlResponse, any Error>) {
        switch result {
        case .success(let response):
            delegate?.didReceive(response)
        case.failure(let error):
            print(error.localizedDescription)
        }
    }
}
