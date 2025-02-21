public enum AnalyticsState {
    case isUserLoggedIn(Bool)
}

public extension AnalyticsState {
    var eventName: String {
        switch self {
        case .isUserLoggedIn:
            return "user_logged_in"
        }
    }

    var eventValue: String {
        switch self {
        case .isUserLoggedIn(let isLoggedIn):
            return isLoggedIn.description
        }
    }
}
