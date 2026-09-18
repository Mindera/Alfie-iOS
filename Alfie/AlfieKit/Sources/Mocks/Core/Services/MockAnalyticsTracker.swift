import AlicerceAnalytics
import Model

public class MockAnalyticsTracker: AnalyticsTracker {
    /// The actions tracked so far, in order — for asserting not just *what* fired but *whether* it
    /// fired at all (e.g. add-to-bag must stay silent when the cart write fails).
    public private(set) var trackedActions: [AnalyticsAction] = []

    /// The events themselves, so a test can assert what one *said* and not only that it fired.
    public private(set) var trackedEvents: [AnalyticsEvent] = []

    public init() { }

    public func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)

        if case .action(let action, _) = event {
            trackedActions.append(action)
        }
    }

    /// The value carried by `parameter` on each tracked `action`, in order.
    public func trackedValues(of parameter: AnalyticsParameter, for action: AnalyticsAction) -> [String] {
        trackedEvents.compactMap { event in
            guard case .action(let tracked, let parameters) = event, tracked == action else { return nil }
            return parameters?[parameter] as? String
        }
    }
}
