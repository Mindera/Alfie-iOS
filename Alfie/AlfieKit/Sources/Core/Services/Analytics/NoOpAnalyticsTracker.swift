import AlicerceAnalytics
import Model

public final class NoOpAnalyticsTracker: AnalyticsTracker {
    public init() {}

    public func track(_: AnalyticsEvent) {}
}
