import AlicerceAnalytics
import Model

public class MockAnalyticsTracker: AnalyticsTracker {
    /// The actions tracked so far, in order — for asserting not just *what* fired but *whether* it
    /// fired at all (e.g. add-to-bag must stay silent when the cart write fails).
    public private(set) var trackedActions: [AnalyticsAction] = []
    /// Positionally aligned with `trackedActions`, so an assertion can reach the identifier an
    /// event carried and not just its name.
    public private(set) var trackedActionParameters: [[AnalyticsParameter: Any]?] = []

    public init() { }

    public func track(_ event: AnalyticsEvent) {
        if case .action(let action, let parameters) = event {
            trackedActions.append(action)
            trackedActionParameters.append(parameters)
        }
    }

    public func trackedProductIDs(for action: AnalyticsAction) -> [String] {
        zip(trackedActions, trackedActionParameters).compactMap { tracked, parameters in
            tracked == action ? parameters?[.productID] as? String : nil
        }
    }
}
