import Foundation

final class LGResponseHandler {
    var onVolumeChange: ((Bool) -> Void)?
    var onAppsListReceived: (([LGRemoteControlResponseApplication]) -> Void)?
    
    func handleResponse(_ response: LGRemoteControlResponse) {
        if response.id == "volumeSubscription" {
            let isMuted = response.payload?.volumeStatus?.muteStatus ?? false
            onVolumeChange?(isMuted)
        } else if response.id == "listAppsRequest" {
            let apps = response.payload?.applications ?? []
            
            let filteredApps = apps.filter({!($0.systemApp ?? false)})
            onAppsListReceived?(filteredApps)
        }
    }
}
