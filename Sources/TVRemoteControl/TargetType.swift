import Foundation
import Moya

enum FireTVAPI {
    case fetchDeviceInfo(ip: String)
    case sendText(ip: String, token: String?, text: String)
    case sendCommand(ip: String, token: String?, action: String)
    case sendMediaCommand(ip: String, token: String?, action: String, body: [String: Any]?)
    case connect(ip: String, friendlyName: String)
    case check(ip: String, token: String?)
    case verifyPin(ip: String, pin: String)
    case getApps(ip: String, token: String?)
    case openApp(ip: String, token: String?, appId: String)
}

extension FireTVAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .fetchDeviceInfo(let ip):
            return URL(string: "http://\(ip):60000")!
        case .sendText(let ip, _, _),
             .sendCommand(let ip, _, _),
             .sendMediaCommand(let ip, _, _, _),
             .connect(let ip, _),
             .check(let ip, _),
             .verifyPin(let ip, _),
             .getApps(let ip, _),
             .openApp(let ip, _, _):
            return URL(string: "https://\(ip):8080")!
        }
    }

    var path: String {
        switch self {
        case .fetchDeviceInfo:
            return "/dd.xml"
        case .sendText:
            return "/v1/FireTV/text"
        case .sendCommand:
            return "/v1/FireTV"
        case .sendMediaCommand:
            return "/v1/media"
        case .connect:
            return "/v1/FireTV/pin/display"
        case .check:
            return "/v1/FireTV"
        case .verifyPin:
            return "/v1/FireTV/pin/verify"
        case .getApps:
            return "/v1/FireTV/apps"
        case .openApp(_, _, let appId):
            return "/v1/FireTV/app/\(appId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchDeviceInfo, .check, .getApps:
            return .get
        default:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .fetchDeviceInfo, .check, .getApps:
            return .requestPlain
        case .sendText(_, _, let text):
            return .requestParameters(parameters: ["text": text], encoding: JSONEncoding.default)
        case .sendCommand(_, _, let action):
            return .requestParameters(parameters: ["action": action], encoding: URLEncoding.queryString)
        case .sendMediaCommand(_, _, let action, let body):
            var parameters: [String: Any] = ["action": action]
            if let body = body {
                parameters.merge(body) { $1 }
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .connect(_, let friendlyName):
            return .requestParameters(parameters: ["friendlyName": friendlyName], encoding: JSONEncoding.default)
        case .verifyPin(_, let pin):
            return .requestParameters(parameters: ["pin": pin], encoding: JSONEncoding.default)
        case .openApp:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .fetchDeviceInfo:
            return [
                "User-Agent": "FireTVRemote/1.1 CFNetwork/1568.300.101 Darwin/24.2.0",
                "Accept": "*/*",
                "Accept-Language": "en-US,en;q=0.9",
                "Connection": "keep-alive"
            ]
        default:
            var headers = [
                "Content-Type": "application/json; charset=utf-8",
                "Connection": "keep-alive",
                "Accept": "*/*",
                "Accept-Language": "ru",
                "Accept-Encoding": "gzip, deflate, br",
                "User-Agent": "Fire Remote/1 CFNetwork/1568.200.51 Darwin/24.1.0"
            ]
            if let token = self.token {
                headers["x-client-token"] = token
            }
            return headers
        }
    }

    private var token: String? {
        switch self {
        case .sendText(_, let token, _),
             .sendCommand(_, let token, _),
             .sendMediaCommand(_, let token, _, _),
             .check(_, let token),
             .getApps(_, let token),
             .openApp(_, let token, _):
            return token
        default:
            return nil
        }
    }
}
