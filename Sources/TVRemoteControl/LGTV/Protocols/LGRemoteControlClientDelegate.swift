import Foundation

public protocol LGRemoteControlClientDelegate: AnyObject {
    func didConnect()
    func didRegister(with clientKey: String)
    func didReceive(_ result: Result<LGRemoteControlResponse, Error>)
    func didReceive(jsonResponse: String)
    func didReceiveNetworkError(_ error: Error?)
    func didDisconnect()
}
