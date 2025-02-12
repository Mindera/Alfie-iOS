import AlicerceAnalytics
import FirebaseAnalytics
import Models

public class FirebaseAnalyticsTracker: AnalyticsTracker {
    public init() {}

    public func track(_ event: AnalyticsEvent) {
        FirebaseAnalytics.Analytics.logEvent(event.name, parameters: event.parameters)
    }
}
