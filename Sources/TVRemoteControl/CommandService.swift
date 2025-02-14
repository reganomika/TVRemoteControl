final class CommandService {
    private let networkManager = NetworkManager.shared
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendText(ip: String?, token: String?, text: String) {
        guard let ip = ip else { return }
        networkManager.sendRequest(to: .sendText(ip: ip, token: token, text: text)) { _ in }
    }
    
    func sendCommand(ip: String?, token: String?, action: String) {
        guard let ip = ip else { return }
        networkManager.sendRequest(to: .sendCommand(ip: ip, token: token, action: action)) { _ in }
    }
    
    func sendMediaCommand(ip: String?, token: String?, action: String, body: [String: Any]?) {
        guard let ip = ip else { return }
        networkManager.sendRequest(to: .sendMediaCommand(ip: ip, token: token, action: action, body: body)) { _ in }
    }
}
