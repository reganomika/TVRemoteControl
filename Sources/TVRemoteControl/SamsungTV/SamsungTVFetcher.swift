import Foundation

public class SamsungTVFetcher: @unchecked Sendable {
    private let session: URLSession
    private var dataTask: URLSessionDataTask?

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchDevice(for tv: SamsungTVModel, completion: @escaping @Sendable (Result<SamsungTVModel, SamsungTVFetcherError>) -> Void) {
        guard let url = URL(string: tv.uri) else {
            completion(.failure(.invalidURL))
            return
        }
        cancelFetch()
        dataTask = session.dataTask(with: url) { data, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(.failedRequest(error, response as? HTTPURLResponse)))
                return
            }
            do {
                let updatedTV = try JSONDecoder().decode(SamsungTVModel.self, from: data)
                completion(.success(updatedTV))
            } catch {
                completion(.failure(.unexpectedResponseBody(data)))
            }
        }
        dataTask?.resume()
    }

    public func cancelFetch() {
        dataTask?.cancel()
    }

    deinit {
        cancelFetch()
    }
}

public enum SamsungTVFetcherError: @unchecked Sendable, Error, Equatable {
    public static func == (lhs: SamsungTVFetcherError, rhs: SamsungTVFetcherError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.failedRequest(let error1, let response1), .failedRequest(let error2, let response2)):
            return "\(String(describing: error1)), \(String(describing: response1))" == "\(String(describing: error2)), \(String(describing: response2))"
        case (.unexpectedResponseBody(let data1), .unexpectedResponseBody(let data2)):
            return data1 == data2
        default:
            return false
        }
    }

    // invalid tv uri
    case invalidURL
    // http request failed or received failure response
    case failedRequest(Error?, HTTPURLResponse?)
    // unexpected response body returned
    case unexpectedResponseBody(Data)
}
