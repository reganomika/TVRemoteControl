public class DeviceService {
    private let networkManager = NetworkManager.shared
    
    public func fetchDeviceInfo(
        ip: String,
        completion: @escaping @Sendable (Result<FireStickInformation, Error>) -> Void
    ) {
        networkManager.sendRequest(to: .fetchDeviceInfo(ip: ip)) { result in
            switch result {
            case .success(let data):
                if let deviceInfo = FireStickParser().parse(data: data) {
                    completion(.success(deviceInfo))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
