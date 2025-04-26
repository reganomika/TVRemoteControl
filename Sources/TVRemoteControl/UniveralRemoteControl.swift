//public enum DeviceType {
//    case samsung
//    case fireStick
//    case lg
//    case roku
//}
//
//public final class UniversalRemoteControl {
//    
//    @MainActor public static let shared = UniversalRemoteControl()
//    
//    public var samsungManager = SamsungTVConnectionService.shared
//    
//    var samsungTV: SamsungTV?
//    
//    private var deviceType: DeviceType?
//    
//    public func connectToSamsung(device: SamsungTVModel, appName: String) {
//        self.deviceType = .samsung
//        samsungManager.connect(to: device, appName: appName, commander: nil)
//    }
//    
//    public func sendCommand(_ command: String) {
//        guard let deviceType = deviceType else { return }
//        switch deviceType {
//        case .samsung:
//            samsungTV?.sendRemoteCommand(key: command)
//        }
//    }
//}
