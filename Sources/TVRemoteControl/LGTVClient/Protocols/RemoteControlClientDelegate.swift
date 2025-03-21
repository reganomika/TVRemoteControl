import Foundation

public protocol RemoteControlClientDelegate: AnyObject {
    func didConnect()
    func didRegister(with clientKey: String)
    func didReceive(_ result: Result<RemoteControlResponse, Error>)
    func didReceive(jsonResponse: String)
    func didReceiveNetworkError(_ error: Error?)
    func didDisconnect()
}
