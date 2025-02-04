import AlicerceAnalytics
import Models

public class DummyAnalyticsTracker: AnalyticsTracker {
    public init() { }
    public func track(_ event: AnalyticsEvent) { }
}
