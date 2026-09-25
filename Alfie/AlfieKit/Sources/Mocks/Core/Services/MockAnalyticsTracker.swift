import AlicerceAnalytics
import Model

public class MockAnalyticsTracker: AnalyticsTracker {
    /// Every event tracked so far, in order — for asserting not just *what* fired but *whether* it
    /// fired at all (e.g. add-to-bag must stay silent when the cart write fails). Each event carries
    /// its own parameters, so nothing has to pair two arrays by position.
    public private(set) var trackedEvents: [AnalyticsEvent] = []

    public var trackedActions: [AnalyticsAction] {
        trackedEvents.compactMap { event in
            guard case .action(let action, _) = event else { return nil }
            return action
        }
    }

    public init() { }

    public func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }

    /// The value carried by `parameter` on each tracked `action`, in order.
    public func trackedValues(of parameter: AnalyticsParameter, for action: AnalyticsAction) -> [String] {
        trackedEvents.compactMap { event in
            guard case .action(let tracked, let parameters) = event, tracked == action else { return nil }
            return parameters?[parameter] as? String
        }
    }

    public func trackedProductIDs(for action: AnalyticsAction) -> [String] {
        trackedValues(of: .productID, for: action)
    }
}
