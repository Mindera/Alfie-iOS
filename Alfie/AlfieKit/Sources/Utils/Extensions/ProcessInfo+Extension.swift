import AccessibilityIdentifiers
import Foundation

extension ProcessInfo {
    public static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    public static let isUITest: Bool = {
        #if DEBUG
        processInfo.environment[UITestSignal.environmentKey] == UITestSignal.enabledValue
        #else
        false
        #endif
    }()

    public static var isSwiftUIPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
