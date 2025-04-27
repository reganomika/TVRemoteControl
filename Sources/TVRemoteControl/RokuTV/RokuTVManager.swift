import Foundation
import Combine
import UIKit

// MARK: - Public Data Models

/// Represents Roku device information
public struct RokuDeviceInfo {
    public let friendlyName: String
    public let modelName: String
    public let softwareVersion: String
    
    public init(friendlyName: String, modelName: String, softwareVersion: String) {
        self.friendlyName = friendlyName
        self.modelName = modelName
        self.softwareVersion = softwareVersion
    }
}

/// Represents a Roku application
public struct RokuApp: Identifiable {
    public let id: String
    public let name: String
    public let version: String
    
    public init(id: String, name: String, version: String) {
        self.id = id
        self.name = name
        self.version = version
    }
}

// MARK: - Error Handling

public enum RokuDeviceError: Error {
    case invalidIPAddress
    case connectionFailed(Error)
    case xmlParsingFailed
    case appListParsingFailed
    case commandFailed
}

// MARK: - Main Controller

/// The main controller for interacting with Roku devices
public final class RokuDeviceManager {
    
    // MARK: - Singleton
    
    @MainActor public static let shared = RokuDeviceManager()
    
    // MARK: - Private Properties
    
    private let session: URLSession = .shared
    private var currentDeviceInfo: RokuDeviceInfo?
    
    // MARK: - Connection Status

    @Published public private(set) var isConnected = false
    
    // MARK: - Device Information
    
    /// Gets the current device info if connected
    public func getDeviceInfo() -> RokuDeviceInfo? {
        currentDeviceInfo
    }
    
    // MARK: - Connection Methods
    
    /// Connects to the Roku device and fetches its information
    /// - Parameter ipAddress: The IP address of the Roku device
    /// - Returns: A publisher that emits the device info
    public func connect(to ipAddress: String) -> AnyPublisher<RokuDeviceInfo, RokuDeviceError> {
        guard !ipAddress.isEmpty else {
            return Fail(error: .invalidIPAddress).eraseToAnyPublisher()
        }
        
        let url = makeURL(ip: ipAddress, path: "/query/device-info")
        
        return session.dataTaskPublisher(for: url)
            .mapError { RokuDeviceError.connectionFailed($0) }
            .map(\.data)
            .tryMap { [weak self] data -> RokuDeviceInfo in
                let deviceInfo = try self?.parseDeviceInfo(from: data)
                self?.currentDeviceInfo = deviceInfo
                self?.isConnected = true
                return deviceInfo!
            }
            .mapError { error in
                self.isConnected = false
                if let rokuError = error as? RokuDeviceError {
                    return rokuError
                }
                return .connectionFailed(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - App Management
    
    /// Fetches the list of installed apps from the Roku device
    /// - Parameter ipAddress: The IP address of the Roku device
    /// - Returns: A publisher that emits the list of apps
    public func fetchInstalledApps(ipAddress: String) -> AnyPublisher<[RokuApp], RokuDeviceError> {
        guard !ipAddress.isEmpty else {
            return Fail(error: .invalidIPAddress).eraseToAnyPublisher()
        }
        
        let url = makeURL(ip: ipAddress, path: "/query/apps")
        
        return session.dataTaskPublisher(for: url)
            .mapError { RokuDeviceError.connectionFailed($0) }
            .map(\.data)
            .tryMap { data -> [RokuApp] in
                try self.parseApps(from: data)
            }
            .mapError { error in
                if let rokuError = error as? RokuDeviceError {
                    return rokuError
                }
                return .appListParsingFailed
            }
            .eraseToAnyPublisher()
    }
    
    /// Launches an app on the Roku device
    /// - Parameters:
    ///   - appId: The ID of the app to launch
    ///   - ipAddress: The IP address of the Roku device
    /// - Returns: A publisher that completes when the command is sent
    public func launchApp(withId appId: String, ipAddress: String) -> AnyPublisher<Void, RokuDeviceError> {
        sendCommand("launch/\(appId)", ipAddress: ipAddress)
    }
    
    // MARK: - Remote Control Commands
    
    /// Sends a key press command to the Roku device
    /// - Parameters:
    ///   - key: The key command to send (e.g., "Home", "Back")
    ///   - ipAddress: The IP address of the Roku device
    /// - Returns: A publisher that completes when the command is sent
    public func sendKeyPress(_ key: String, ipAddress: String) -> AnyPublisher<Void, RokuDeviceError> {
        sendCommand("keypress/\(key)", ipAddress: ipAddress)
    }
    
    /// Fetches the icon for a specific app
    /// - Parameters:
    ///   - appId: The ID of the app
    ///   - ipAddress: The IP address of the Roku device
    /// - Returns: A publisher that emits the app icon
    public func fetchAppIcon(appId: String, ipAddress: String) -> AnyPublisher<UIImage?, RokuDeviceError> {
        guard !ipAddress.isEmpty else {
            return Fail(error: .invalidIPAddress).eraseToAnyPublisher()
        }
        
        let url = makeURL(ip: ipAddress, path: "/query/icon/\(appId)")
        
        return session.dataTaskPublisher(for: url)
            .mapError { .connectionFailed($0) }
            .map { UIImage(data: $0.data) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func sendCommand(_ path: String, ipAddress: String) -> AnyPublisher<Void, RokuDeviceError> {
        guard !ipAddress.isEmpty else {
            return Fail(error: .invalidIPAddress).eraseToAnyPublisher()
        }
        
        let url = makeURL(ip: ipAddress, path: path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return session.dataTaskPublisher(for: request)
            .mapError { RokuDeviceError.connectionFailed($0) }
            .tryMap { _ in () }
            .mapError { error in
                if let rokuError = error as? RokuDeviceError {
                    return rokuError
                }
                return .commandFailed
            }
            .eraseToAnyPublisher()
    }
    
    private func makeURL(ip: String, path: String) -> URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = ip
        components.port = 8060
        components.path = path
        
        guard let url = components.url else {
            fatalError("Invalid URL components")
        }
        
        return url
    }
    
    private func parseDeviceInfo(from data: Data) throws -> RokuDeviceInfo {
        let parser = DeviceInfoXMLParser()
        return try parser.parse(from: data)
    }
    
    private func parseApps(from data: Data) throws -> [RokuApp] {
        let parser = RokuAppsJSONParser()
        return try parser.parse(from: data)
    }
}

// MARK: - Parsers

private final class DeviceInfoXMLParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var result = RokuDeviceInfo(friendlyName: "", modelName: "", softwareVersion: "")
    private var parsingError: Error?
    
    func parse(from data: Data) throws -> RokuDeviceInfo {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        if let error = parsingError {
            throw error
        }
        
        return result
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "friendly-device-name":
            result = RokuDeviceInfo(
                friendlyName: trimmed,
                modelName: result.modelName,
                softwareVersion: result.softwareVersion
            )
        case "model-name":
            result = RokuDeviceInfo(
                friendlyName: result.friendlyName,
                modelName: trimmed,
                softwareVersion: result.softwareVersion
            )
        case "software-version":
            result = RokuDeviceInfo(
                friendlyName: result.friendlyName,
                modelName: result.modelName,
                softwareVersion: trimmed
            )
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        parsingError = parseError
    }
}

private struct RokuAppsJSONParser {
    struct Response: Decodable {
        let apps: [App]
        
        struct App: Decodable {
            let id: String
            let name: String
            let version: String
        }
    }
    
    func parse(from data: Data) throws -> [RokuApp] {
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            return response.apps.map { RokuApp(id: $0.id, name: $0.name, version: $0.version) }
        } catch {
            throw RokuDeviceError.appListParsingFailed
        }
    }
}

public enum RokuKeyCommand: String, CaseIterable {
    
    // Navigation
    case home = "Home"
    case back = "Back"
    case up = "Up"
    case down = "Down"
    case left = "Left"
    case right = "Right"
    case select = "Select"
    
    // Playback controls
    case rev = "Rev"
    case fwd = "Fwd"
    case play = "Play"
    case pause = "Pause"
    case stop = "Stop"
    case instantReplay = "InstantReplay"
    case info = "Info"
    
    // Text input
    case backspace = "Backspace"
    case search = "Search"
    case enter = "Enter"
    
    // Volume controls
    case volumeUp = "VolumeUp"
    case volumeDown = "VolumeDown"
    case volumeMute = "VolumeMute"
    
    // Numbers
    case num0 = "0"
    case num1 = "1"
    case num2 = "2"
    case num3 = "3"
    case num4 = "4"
    case num5 = "5"
    case num6 = "6"
    case num7 = "7"
    case num8 = "8"
    case num9 = "9"
    
    // Power
    case power = "Power"
    case powerOn = "PowerOn"
    case powerOff = "PowerOff"
    
    // Channels
    case channelUp = "ChannelUp"
    case channelDown = "ChannelDown"
}

extension RokuDeviceManager {
    /// Sends a key press command to the Roku device
    /// - Parameters:
    ///   - command: The key command to send
    ///   - ipAddress: The IP address of the Roku device
    /// - Returns: A publisher that completes when the command is sent
    public func sendKeyPress(_ command: RokuKeyCommand, ipAddress: String) -> AnyPublisher<Void, RokuDeviceError> {
        sendCommand("keypress/\(command.rawValue)", ipAddress: ipAddress)
    }
}
