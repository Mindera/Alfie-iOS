import UIKit

public enum ExternalAppLauncher {
    public static func open(url: URL) {
        UIApplication.shared.open(url)
    }

    /// This app's page in the system Settings — the only place a permission the shopper has already
    /// refused can be granted. The URL is a system constant, so the optional it arrives in is
    /// unwrapped once here rather than at every call site that wants the door.
    public static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        open(url: url)
    }
}
