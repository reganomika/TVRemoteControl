import Foundation
import Moya

final class AuthService {
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
        networkManager.sendRequest(to: .connect(ip: ip, friendlyName: friendlyName)) { result in
            completion(result.map { _ in true })
        }
    }
    
    func check(
        ip: String?,
        token: String?,
        completion: @escaping @Sendable (Result<Data, Error>) -> Void
    ) {
        guard let ip = ip else { return }
        networkManager.sendRequest(to: .check(ip: ip, token: token), completion: completion)
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
        
        networkManager.sendRequest(to: .verifyPin(ip: device.ip, pin: pin)) { result in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let token = json["description"] {
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
}
