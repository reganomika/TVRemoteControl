import Foundation

public class DeviceService {
    private let networkManager = NetworkManager.shared
    
    public func fetchDeviceInfo(
        ip: String,
        completion: @escaping @Sendable (Result<FireStickInformation, Error>) -> Void
    ) {
        guard let url = URL(string: "http://\(ip):60000/dd.xml") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "User-Agent": "FireTVRemote/1.1 CFNetwork/1568.300.101 Darwin/24.2.0",
            "Accept": "*/*",
            "Accept-Language": "en-US,en;q=0.9",
            "Connection": "keep-alive"
        ]
        
        networkManager.sendRequest(to: url, method: "GET", headers: request.allHTTPHeaderFields ?? [:]) { result in
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
