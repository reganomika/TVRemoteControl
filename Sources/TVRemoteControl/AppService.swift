import Foundation
import Moya

public struct App: Decodable {
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

final class AppService {
    private let networkManager = NetworkManager.shared
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getApps(
        ip: String?,
        token: String?,
        completion: @escaping @Sendable (Result<[App], Error>) -> Void
    ) {
        guard let ip = ip else { return }
        
        networkManager.sendRequest(to: .getApps(ip: ip, token: token)) { result in
            switch result {
            case .success(let data):
                do {
                    let apps = try JSONDecoder().decode([App].self, from: data)
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
        app: App
    ) {
        guard let ip = ip else { return }
        networkManager.sendRequest(to: .openApp(ip: ip, token: token, appId: app.appId)) { _ in }
    }
}
