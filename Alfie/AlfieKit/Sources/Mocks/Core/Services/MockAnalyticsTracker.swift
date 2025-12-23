import AlicerceAnalytics
import Model

public class MockAnalyticsTracker: AnalyticsTracker {
    public init() { }
    public func track(_ event: AnalyticsEvent) { }
}
