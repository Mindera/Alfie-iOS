import AlicerceAnalytics
import FirebaseAnalytics
import Model

public class FirebaseAnalyticsTracker: AnalyticsTracker {
    public init() {}

    public func track(_ event: AnalyticsEvent) {
        switch event {
        case .state(let state, _):
            FirebaseAnalytics.Analytics.setUserProperty(state.eventValue, forName: state.eventName)

        case .action(let action, _):
            FirebaseAnalytics.Analytics.logEvent(action.rawValue, parameters: event.parameters)
        }
    }
}
