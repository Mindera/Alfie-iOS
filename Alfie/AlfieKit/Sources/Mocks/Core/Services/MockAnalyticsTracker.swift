import AlicerceAnalytics
import Models

public class MockAnalyticsTracker: AnalyticsTracker {
    public init() { }
    public func track(_ event: AnalyticsEvent) { }
}
