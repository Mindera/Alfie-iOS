import FirebaseAnalytics
import Models

public final class FirebaseAnalyticsService: TrackingProviderProtocol {
    public let id: String = "com.firebase.analytics"
    public private(set) var isEnabled = true

    public init() {}

    public func enable() {
        isEnabled = true
    }

    public func disable() {
        isEnabled = false
    }

    public func track(name: String?, parameters: [String: Any]?) {
        guard let name else {
            return
        }
        Analytics.logEvent(name, parameters: parameters)
    }
}
