import UIKit

public enum ExternalAppLauncher {
    public static func open(url: URL) {
        UIApplication.shared.open(url)
    }
}
