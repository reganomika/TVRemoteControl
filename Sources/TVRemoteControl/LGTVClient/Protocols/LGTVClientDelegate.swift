import Foundation

public protocol LGTVClientDelegate: AnyObject {
    func didConnect()
    func didRegister(with clientKey: String)
    func didReceive(_ result: Result<LGTVResponse, Error>)
    func didReceive(jsonResponse: String)
    func didReceiveNetworkError(_ error: Error?)
    func didDisconnect()
}
