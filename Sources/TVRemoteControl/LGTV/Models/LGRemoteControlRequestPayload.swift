import Foundation

public struct LGRemoteControlRequestPayload: Codable {
    public var pin: String?
    public var forcePairing: Bool?
    public var manifest: LGRemoteControlRequestManifest?
    public var pairingType: String?
    public var clientKey: String?
    public var message: String?
    public var iconData: Data?
    public var iconExtension: String?
    public var volume: Int?
    public var mute: Bool?
    public var output: String?
    public var standbyMode: String?
    public var id: String?
    public var contentId: String?
    public var params: String?
    public var sessionId: String?
    public var text: String?
    public var replace: Bool?
    public var count: Int?
    public var inputId: String?
    public var category: String?
    public var keys: [String]?

    public init(
        pin: String? = nil,
        forcePairing: Bool? = nil,
        manifest: LGRemoteControlRequestManifest? = nil,
        pairingType: String? = nil,
        clientKey: String? = nil,
        message: String? = nil,
        iconData: Data? = nil,
        iconExtension: String? = nil,
        volume: Int? = nil,
        mute: Bool? = nil,
        output: String? = nil,
        standbyMode: String? = nil,
        id: String? = nil,
        contentId: String? = nil,
        params: String? = nil,
        sessionId: String? = nil,
        text: String? = nil,
        replace: Bool? = nil,
        count: Int? = nil,
        inputId: String? = nil,
        category: String? = nil,
        keys: [String]? = nil
    ) {
        self.pin = pin
        self.forcePairing = forcePairing
        self.manifest = manifest
        self.pairingType = pairingType
        self.clientKey = clientKey
        self.message = message
        self.iconData = iconData
        self.iconExtension = iconExtension
        self.volume = volume
        self.mute = mute
        self.output = output
        self.standbyMode = standbyMode
        self.id = id
        self.contentId = contentId
        self.params = params
        self.sessionId = sessionId
        self.text = text
        self.replace = replace
        self.count = count
        self.inputId = inputId
        self.category = category
        self.keys = keys
    }

    public enum CodingKeys: String, CodingKey {
        case clientKey = "client-key"
        case pin
        case forcePairing
        case manifest
        case pairingType
        case message
        case iconData
        case iconExtension
        case volume
        case mute
        case output
        case standbyMode
        case id
        case contentId
        case params
        case sessionId
        case text
        case replace
        case count
        case inputId
        case category
        case keys
    }

}
