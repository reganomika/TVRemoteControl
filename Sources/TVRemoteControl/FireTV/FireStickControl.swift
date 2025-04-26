import Foundation

public struct FireStick: Hashable, Codable {
    public init(name: String, ip: String) {
        self.name = name
        self.ip = ip
    }
    
    public let name: String
    public let ip: String
}

public struct FireStickInformation {
    public init(friendlyName: String) {
        self.friendlyName = friendlyName
    }
    
    public let friendlyName: String
}

public class FireStickParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var parsedData: [String: String] = [:]
    
    public func parse(data: Data) -> FireStickInformation? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        return parser.parse() ? FireStickInformation(
            friendlyName: parsedData["friendlyName"] ?? ""
        ) : nil
    }
    
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        currentElement = elementName
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        parsedData[currentElement, default: ""] += string
    }
}

public enum FireStickError: Error {
    case invalidCode
    case invalidFormat
}

public class FireStickControl: @unchecked Sendable {
    public static let shared = FireStickControl()
    
    private lazy var authService = FireStickAuthService(apiKey: apiKey)
    private lazy var commandService = FireStickCommandService(apiKey: apiKey)
    private lazy var appService = FireStickAppService(apiKey: apiKey)
    private let deviceService = FireStickDeviceService()
    
    private var apiKey: String = ""
    
    @Published public var isConnected: Bool = false
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func connect(ip: String, friendlyName: String, completion: @escaping @Sendable (Result<Bool, Error>) -> Void) {
        authService.connect(ip: ip, friendlyName: friendlyName, completion: completion)
    }
    
    public func verifyPin(pin: String, device: FireStick, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
        authService.verifyPin(pin: pin, device: device) { [weak self] result in
            
            switch result {
            case .success(let token):
                self?.isConnected = true
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func check(
        ip: String?,
        token: String?,
        completion: @escaping @Sendable (Result<Data, Error>) -> Void
    ) {
        authService.check(ip: ip, token: token, completion: completion)
    }
    
    public func sendText(
        ip: String?,
        token: String?,
        text: String
    ) {
        commandService.sendText(ip: ip, token: token, text: text)
    }
    
    public func sendCommand(
        ip: String?,
        token: String?,
        action: String
    ) {
        commandService.sendCommand(ip: ip, token: token, action: action)
    }
    
    public func getApps(
        ip: String?,
        token: String?,
        completion: @escaping @Sendable (Result<[FireStickApp], Error>) -> Void
    ) {
        appService.getApps(ip: ip, token: token, completion: completion)
    }
    
    public func sendMediaCommand(
        ip: String?,
        token: String?,
        action: String,
        body: [String: Any]? = nil
    ) {
        commandService.sendMediaCommand(ip: ip, token: token, action: action, body: body)
    }
    
    public func openApp(
        app: FireStickApp,
        ip: String?,
        token: String?
    ) {
        appService.openApp(ip: ip, token: token, app: app)
    }
    
    public func fetchDeviceInfo(ip: String, completion: @escaping @Sendable (Result<FireStickInformation, Error>) -> Void) {
        deviceService.fetchDeviceInfo(ip: ip, completion: completion)
    }
}
