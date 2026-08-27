import AlicerceAnalytics
import Model

public class MockAnalyticsTracker: AnalyticsTracker {
    /// The actions tracked so far, in order — for asserting not just *what* fired but *whether* it
    /// fired at all (e.g. add-to-bag must stay silent when the cart write fails).
    public private(set) var trackedActions: [AnalyticsAction] = []

    public init() { }

    public func track(_ event: AnalyticsEvent) {
        if case .action(let action, _) = event {
            trackedActions.append(action)
        }
    }
}
