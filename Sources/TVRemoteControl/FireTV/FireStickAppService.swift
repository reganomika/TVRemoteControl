import Foundation

public struct FireStickApp: Decodable {
    public init(appId: String, name: String, iconArtSmallUri: String, isInstalled: Bool) {
        self.appId = appId
        self.name = name
        self.iconArtSmallUri = iconArtSmallUri
        self.isInstalled = isInstalled
    }
    
    public let appId: String
    public let name: String
    public let iconArtSmallUri: String
    public let isInstalled: Bool
}

final class FireStickAppService {
    private let networkManager = NetworkManager.shared
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getApps(
        ip: String?,
        token: String?,
        completion: @escaping @Sendable (Result<[FireStickApp], Error>) -> Void
    ) {
        guard let ip ,
              let url = URL(string: "https://\(ip):8080/v1/FireTV/apps") else {
            return
        }
        
        networkManager.sendRequest(to: url, method: "GET", headers: defaultHeaders(token: token)) { result in
            switch result {
            case .success(let data):
                do {
                    let apps = try JSONDecoder().decode([FireStickApp].self, from: data)
                    completion(.success(apps))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func openApp(
        ip: String?,
        token: String?,
        app: FireStickApp
    ) {
        guard let ip, let url = URL(string: "https://\(ip):8080/v1/FireTV/app/\(app.appId)") else {
            return
        }
                
        networkManager.sendRequest(to: url, method: "POST", headers: defaultHeaders(token: token)) { result in }
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
