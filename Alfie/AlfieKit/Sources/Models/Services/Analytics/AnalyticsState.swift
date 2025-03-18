public enum AnalyticsState {
    case isUserSignIn(Bool)
}

public extension AnalyticsState {
    var eventName: String {
        switch self {
        case .isUserSignIn:
            return "user_sign_in"
        }
    }

    var eventValue: String {
        switch self {
        case .isUserSignIn(let isSignIn):
            return isSignIn.description
        }
    }
}
