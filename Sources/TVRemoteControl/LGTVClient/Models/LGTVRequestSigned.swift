import Foundation

public struct LGTVRequestSigned: Codable {
    public init(appId: String = "com.lge.test", created: String = "20140509", localizedAppNames: [String : String] = [
        "": "LG Remote App",
        "ko-KR": "리모컨 앱",
        "zxx-XX": "ЛГ Rэмotэ AПП"
    ], localizedVendorNames: [String : String] = [
        "": "LG Electronics"
    ], permissions: [String] = [
        "TEST_SECURE",
        "CONTROL_INPUT_TEXT",
        "CONTROL_MOUSE_AND_KEYBOARD",
        "READ_INSTALLED_APPS",
        "READ_LGE_SDX",
        "READ_NOTIFICATIONS",
        "SEARCH",
        "WRITE_SETTINGS",
        "WRITE_NOTIFICATION_ALERT",
        "CONTROL_POWER",
        "READ_CURRENT_CHANNEL",
        "READ_RUNNING_APPS",
        "READ_UPDATE_INFO",
        "UPDATE_FROM_REMOTE_APP",
        "READ_LGE_TV_INPUT_EVENTS",
        "READ_TV_CURRENT_TIME"
    ], serial: String = "2f930e2d2cfe083771f68e4fe7bb07", vendorId: String = "com.lge") {
        self.appId = appId
        self.created = created
        self.localizedAppNames = localizedAppNames
        self.localizedVendorNames = localizedVendorNames
        self.permissions = permissions
        self.serial = serial
        self.vendorId = vendorId
    }
    
    public var appId: String = "com.lge.test"
    public var created: String = "20140509"
    public var localizedAppNames: [String: String] = [
        "": "LG Remote App",
        "ko-KR": "리모컨 앱",
        "zxx-XX": "ЛГ Rэмotэ AПП"
    ]
    public var localizedVendorNames: [String: String] = [
        "": "LG Electronics"
    ]
    public var permissions: [String] = [
        "TEST_SECURE",
        "CONTROL_INPUT_TEXT",
        "CONTROL_MOUSE_AND_KEYBOARD",
        "READ_INSTALLED_APPS",
        "READ_LGE_SDX",
        "READ_NOTIFICATIONS",
        "SEARCH",
        "WRITE_SETTINGS",
        "WRITE_NOTIFICATION_ALERT",
        "CONTROL_POWER",
        "READ_CURRENT_CHANNEL",
        "READ_RUNNING_APPS",
        "READ_UPDATE_INFO",
        "UPDATE_FROM_REMOTE_APP",
        "READ_LGE_TV_INPUT_EVENTS",
        "READ_TV_CURRENT_TIME"
    ]
    public var serial: String = "2f930e2d2cfe083771f68e4fe7bb07"
    public var vendorId: String = "com.lge"
}
