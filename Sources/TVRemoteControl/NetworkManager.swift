import Foundation
import Combine

final class NetworkManager: @unchecked Sendable {
    
    static let shared = NetworkManager()
    
    let session = URLSession(
        configuration: .default,
        delegate: MySessionDelegate(),
        delegateQueue: nil
    )
    
    func sendRequest(
        to url: URL,
        method: String,
        headers: [String: String] = [:],
        body: [String: Any]? = nil,
        completion: @escaping @Sendable (Result<Data, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    completion(.success(data))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
