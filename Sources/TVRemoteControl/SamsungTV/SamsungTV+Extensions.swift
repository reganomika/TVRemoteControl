import Foundation

// MARK: Data

extension Data {
    public static func magicPacket(from device: SamsungTVWakeOnLANDevice) -> Data {
        var magicPacketRaw = [UInt8](repeating: 0xFF, count: 6)
        let macAddressData = device.mac.split(separator: ":").compactMap { UInt8($0, radix: 16) }
        for _ in 0..<16 { magicPacketRaw.append(contentsOf: macAddressData) }
        return Data(magicPacketRaw)
    }

    public var asJSON: [String: Any]? {
        try? JSONSerialization.jsonObject(with: self) as? [String: Any]
    }

    public var asString: String? {
        String(data: self, encoding: .utf8)
    }
}

// MARK: Dictionary

extension Dictionary {
    public var asData: Data? {
        try? JSONSerialization.data(withJSONObject: self)
    }

    public var asString: String? {
        asData?.asString
    }
}

// MARK: Encodable

extension Encodable {
    public func asString(encoder: JSONEncoder = .init()) throws -> String? {
        try encoder.encode(self).asString
    }
}

// MARK: String

extension String {
    public var isValidAppName: Bool {
        !isEmpty
    }

    public var isValidIPAddress: Bool {
        let regex = #"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }

    public  var asBase64: String? {
        asData?.base64EncodedString()
    }

    public var asData: Data? {
        data(using: .utf8)
    }

    public  var asJSON: [String: Any]? {
        asData.flatMap(\.asJSON)
    }
}

// MARK: TV

extension SamsungTVModel {
    public var ipAddress: String? {
        if let httpURLHost = URLComponents(string: uri)?.host,
           httpURLHost.isValidIPAddress {
            return httpURLHost
        } else if let deviceIPAddress = device?.ip,
                  deviceIPAddress.isValidIPAddress {
            return deviceIPAddress
        }
        return nil
    }

    public func addingDevice(_ device: SamsungTVModel.Device) -> SamsungTVModel {
        SamsungTVModel(
            device: device,
            id: id,
            isSupport: isSupport,
            name: name,
            remote: remote,
            type: type,
            uri: uri,
            version: version
        )
    }
}

// MARK: TVApp

extension SamsungTVApp {
    public static func allApps() -> [SamsungTVApp] {
        [
            espn(),
            hulu(),
            max(),
            netflix(),
            paramountPlus(),
            plutoTV(),
            primeVideo(),
            spotify(),
            youtube()
        ]
    }

    public static func espn() -> SamsungTVApp {
        SamsungTVApp(id: "3201708014618", name: "ESPN")
    }

    public static func hulu() -> SamsungTVApp {
        SamsungTVApp(id: "3201601007625", name: "Hulu")
    }

    public static func max() -> SamsungTVApp {
        SamsungTVApp(id: "3202301029760", name: "Max")
    }

    public static func netflix() -> SamsungTVApp {
        SamsungTVApp(id: "3201907018807", name: "Netflix")
    }

    public static func paramountPlus() -> SamsungTVApp {
        SamsungTVApp(id: "3201710014981", name: "Paramount +")
    }

    public static func plutoTV() -> SamsungTVApp {
        SamsungTVApp(id: "3201808016802", name: "Pluto TV")
    }

    public static func primeVideo() -> SamsungTVApp {
        SamsungTVApp(id: "3201910019365", name: "Prime Video")
    }

    public static func spotify() -> SamsungTVApp {
        SamsungTVApp(id: "3201606009684", name: "Spotify")
    }

    public static func youtube() -> SamsungTVApp {
        SamsungTVApp(id: "111299001912", name: "YouTube")
    }
}

// MARK: TVConnectionConfiguration

extension SamsungTVConnectionConfiguration {
    public func wssURL() -> URL? {
        var components = URLComponents()
        components.path = path
        components.host = ipAddress
        components.port = port
        components.scheme = scheme
        var queryItems = [URLQueryItem]()
        app.asBase64.flatMap { queryItems.append(.init(name: "name", value: $0)) }
        token.flatMap { queryItems.append(.init(name: "token", value: $0)) }
        components.queryItems = queryItems
        return components.url?.removingPercentEncoding
    }
}

// MARK: TVKeyboardLayout

extension TVKeyboardLayout {
    public static var qwerty: Self {
        [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
            ["z", "x", "c", "v", "b", "n", "m"]
        ]
    }

    public static var youtube: Self {
        [
            ["a", "b", "c", "d", "e", "f", "g"],
            ["h", "i", "j", "k", "l", "m", "n"],
            ["o", "p", "q", "r", "s", "t", "u"],
            ["v", "w", "x", "y", "z", "-", "'"],
        ]
    }
}

// MARK: TVRemoteCommand

extension SamsungTVRemoteCommand {
    public static func createClickCommand(_ key: SamsungTVRemoteCommand.Params.ControlKey) -> SamsungTVRemoteCommand {
        SamsungTVRemoteCommand(
            method: .control,
            params: .init(
                cmd: .click,
                dataOfCmd: key,
                option: false,
                typeOfRemote: .remoteKey
            )
        )
    }

    public static func createPressCommand(_ key: SamsungTVRemoteCommand.Params.ControlKey) -> SamsungTVRemoteCommand {
        SamsungTVRemoteCommand(
            method: .control,
            params: .init(
                cmd: .press,
                dataOfCmd: key,
                option: false,
                typeOfRemote: .remoteKey
            )
        )
    }

    public static func createReleaseCommand(_ key: SamsungTVRemoteCommand.Params.ControlKey) -> SamsungTVRemoteCommand {
        SamsungTVRemoteCommand(
            method: .control,
            params: .init(
                cmd: .release,
                dataOfCmd: key,
                option: false,
                typeOfRemote: .remoteKey
            )
        )
    }

    public static func createTextInputCommand(_ text: String) -> SamsungTVRemoteCommand {
        SamsungTVRemoteCommand(
            method: .control,
            params: .init(
                cmd: .textInput(Data(text.utf8).base64EncodedString()),
                dataOfCmd: .base64,
                option: false,
                typeOfRemote: .inputString
            )
        )
    }
}


// MARK: URL

extension URL {
    public var removingPercentEncoding: URL? {
        absoluteString.removingPercentEncoding.flatMap(URL.init(string:))
    }
}

