import Foundation

public struct FireStickVerifyResult {
    public let token: String
}

final class FireStickAuthService {
    private let networkManager = NetworkManager.shared
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func connect(
        ip: String,
        friendlyName: String,
        completion: @escaping @Sendable (Result<Bool, Error>) -> Void
    ) {
        guard let url = URL(string: "https://\(ip):8080/v1/FireTV/pin/display") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "POST", headers: defaultHeaders(), body: ["friendlyName": friendlyName]) { result in
            completion(result.map { _ in true })
        }
    }
    
    func check(ip: String?, token: String?, completion: @escaping @Sendable (Result<Data, Error>) -> Void) {
        guard let ip, let url = URL(string: "https://\(ip):8080/v1/FireTV") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "GET", headers: defaultHeaders(token: token), completion: completion)
    }
    
    func verifyPin(
        pin: String,
        device: FireStick,
        completion: @escaping @Sendable (Result<String, Error>) -> Void
    ) {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            completion(.failure(FireStickError.invalidFormat))
            return
        }
        
        guard let url = URL(string: "https://\(device.ip):8080/v1/FireTV/pin/verify") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "POST", headers: defaultHeaders(), body: ["pin": pin]) { result in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String], let token = json["description"] {
                    if token.isEmpty {
                        completion(.failure(FireStickError.invalidCode))
                    } else {
                        completion(.success(token))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func defaultHeaders(token: String? = nil) -> [String: String] {
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
