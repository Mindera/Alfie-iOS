import AlicerceAnalytics

public typealias AnalyticsEvent = Analytics.Event<AnalyticsState, AnalyticsAction, AnalyticsParameter>

public extension AnalyticsEvent {
    var parameters: [String: Any]? {
        switch self {
        case let .state(_, parameters), let .action(_, parameters):
            return parameters?.mapKeys { $0.rawValue }
        }
    }
}

private extension Dictionary {
    func mapKeys<NewKey: Hashable>(_ transform: (Key) -> NewKey) -> [NewKey: Value] {
        .init(map { (transform($0.key), $0.value) }) { first, _ in first }
    }
}
