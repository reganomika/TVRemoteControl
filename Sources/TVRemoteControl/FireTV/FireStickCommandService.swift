import Foundation

final class FireStickCommandService {
    
    private let networkManager = NetworkManager.shared
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendText(
        ip: String?,
        token: String?,
        text: String
    ) {
        guard !text.isEmpty, let ip else {
            return
        }
        
        guard let url = URL(string: "https://\(ip):8080/v1/FireTV/text") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "POST", headers: defaultHeaders(token: token), body: ["text": text]) { result in }
        
    }
    
    func sendCommand(
        ip: String?,
        token: String?,
        action: String
    ) {
        guard let ip, let url = URL(string: "https://\(ip):8080/v1/FireTV?action=\(action)") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "POST", headers: defaultHeaders(token: token)) { result in }
        
    }
    
    func sendMediaCommand(
        ip: String?,
        token: String?,
        action: String,
        body: [String: Any]? = nil
    ) {
        guard let ip, let url = URL(string: "https://\(ip):8080/v1/media?action=\(action)") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "POST", headers: defaultHeaders(token: token), body: body) { result in }

    }
    
    private func defaultHeaders(token: String?) -> [String: String] {
        var headers = [
            "x-api-key": apiKey,
            "Content-Type": "application/json; charset=utf-8",
            "Connection": "keep-alive",
            "Accept": "*/*",
            "Accept-Language": "ru",
            "Accept-Encoding": "gzip, deflate, br",
            "User-Agent": "Fire Remote/1 CFNetwork/1568.200.51 Darwin/24.1.0"
        ]
        if let token {
            headers["x-client-token"] = token
        }
        return headers
    }
}
