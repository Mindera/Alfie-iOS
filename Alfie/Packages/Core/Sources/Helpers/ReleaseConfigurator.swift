import Foundation

public enum ReleaseConfigurator {
    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    public enum AppType {
        case debug
        case testFlight
        case appStore
    }

    // This can be used to add debug statements.
    public static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    public static var isRelease: Bool {
        appConfiguration == .appStore
    }

    public static var appConfiguration: AppType {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }
}
