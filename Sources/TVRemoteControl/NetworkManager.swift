import Foundation
import Moya
import Combine

final class NetworkManager: @unchecked Sendable {
    static let shared = NetworkManager()
    
    private let provider = MoyaProvider<FireTVAPI>(plugins: [NetworkLoggerPlugin()])
    
    func sendRequest(
        to target: FireTVAPI,
        completion: @escaping @Sendable (Result<Data, Error>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
