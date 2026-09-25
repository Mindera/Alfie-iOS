import AlicerceAnalytics
import Model

public class MockAnalyticsTracker: AnalyticsTracker {
    /// Every action tracked so far paired with the parameters it carried, in order — for asserting
    /// not just *what* fired but *whether* it fired at all (e.g. add-to-bag must stay silent when
    /// the cart write fails).
    public private(set) var tracked: [(action: AnalyticsAction, parameters: [AnalyticsParameter: Any]?)] = []

    public var trackedActions: [AnalyticsAction] {
        tracked.map(\.action)
    }

    public init() { }

    public func track(_ event: AnalyticsEvent) {
        if case .action(let action, let parameters) = event {
            tracked.append((action, parameters))
        }
    }

    public func trackedProductIDs(for action: AnalyticsAction) -> [String] {
        tracked.compactMap { $0.action == action ? $0.parameters?[.productID] as? String : nil }
    }
}
