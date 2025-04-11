import Foundation

public protocol SamsungTVAppManaging {
    func fetchStatus(for tvApp: SamsungTVApp, tvIPAddress: String) async throws -> SamsungTVAppStatus
    func launch(tvApp: SamsungTVApp, tvIPAddress: String) async throws
}

enum SamsungTVAppManagerError: LocalizedError {
    case badURL(description: String)
    case noData
    case networkError(description: String)

    var errorDescription: String? {
        switch self {
        case .badURL(let description):
            return "Bad URL: \(description)"
        case .noData:
            return "No data received from the network."
        case .networkError(let description):
            return "Network error: \(description)"
        }
    }
}

public class SamsungTVAppManager: SamsungTVAppManaging {
    private let urlBuilder: SamsungTVAppURLBuilding
    private let networkManager: SamsungTVAppNetworkManaging
    private let decoder: SamsungTVAppDecoding

    public init(
        urlBuilder: SamsungTVAppURLBuilding = SamsungTVAppURLBuilder(),
        networkManager: SamsungTVAppNetworkManaging = SamsungTVAppNetworkManager(),
        decoder: SamsungTVAppDecoding = SamsungTVAppDecoder()
    ) {
        self.urlBuilder = urlBuilder
        self.networkManager = networkManager
        self.decoder = decoder
    }

    public func fetchStatus(for tvApp: SamsungTVApp, tvIPAddress: String) async throws -> SamsungTVAppStatus {
        let url = try buildURL(tvApp: tvApp, tvIPAddress: tvIPAddress)
        guard let data = try await networkManager.sendRequest(url: url) else {
            throw SamsungTVAppManagerError.noData
        }
        return try decoder.decodeAppStatus(from: data)
    }

    public func launch(tvApp: SamsungTVApp, tvIPAddress: String) async throws {
        let url = try buildURL(tvApp: tvApp, tvIPAddress: tvIPAddress)
        try await networkManager.sendRequest(url: url, method: "POST")
    }

    private func buildURL(tvApp: SamsungTVApp, tvIPAddress: String) throws -> URL {
        if let url = urlBuilder.buildURL(tvIPAddress: tvIPAddress, tvAppId: tvApp.id) {
            return url
        } else {
            throw SamsungTVAppManagerError.badURL(description: "Unable to build URL for IP: \(tvIPAddress)")
        }
    }
}

// MARK: - Build App URL

public protocol SamsungTVAppURLBuilding {
    func buildURL(tvIPAddress: String, tvAppId: String) -> URL?
}

public class SamsungTVAppURLBuilder: SamsungTVAppURLBuilding {
    public init() {
    }

    public func buildURL(tvIPAddress: String, tvAppId: String) -> URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = tvIPAddress
        components.port = 8001
        components.path = "/api/v2/applications/\(tvAppId)"
        return components.url
    }
}

// MARK: - Send HTTP Request

public protocol SamsungTVAppNetworkManaging {
    @discardableResult
    func sendRequest(url: URL, method: String) async throws -> Data?
}

extension SamsungTVAppNetworkManaging {
    func sendRequest(url: URL) async throws -> Data? {
        try await sendRequest(url: url, method: "GET")
    }
}

enum TVAppNetworkError: LocalizedError {
    case appNotFound
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .appNotFound:
            return "App Not Found"
        case .invalidResponse:
            return "Invalid Response"
        }
    }
}

public class SamsungTVAppNetworkManager: SamsungTVAppNetworkManaging {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func sendRequest(url: URL, method: String) async throws -> Data? {
        var request = URLRequest(url: url)
        request.httpMethod = method
        let (data, response) = try await session.data(for: request)
        try validate(response: response)
        return data
    }

    private func validate(response: URLResponse) throws {
        switch (response as? HTTPURLResponse)?.statusCode {
        case 200:
            return
        case 404:
            throw TVAppNetworkError.appNotFound
        default:
            throw TVAppNetworkError.invalidResponse
        }
    }
}

// MARK: Decode App Status

public protocol SamsungTVAppDecoding {
    func decodeAppStatus(from data: Data) throws -> SamsungTVAppStatus
}

public class SamsungTVAppDecoder: SamsungTVAppDecoding {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    public func decodeAppStatus(from data: Data) throws -> SamsungTVAppStatus {
        try decoder.decode(SamsungTVAppStatus.self, from: data)
    }
}
