public enum AnalyticsState {
    case isUserSignedIn(Bool)
}

public extension AnalyticsState {
    var eventName: String {
        switch self {
        case .isUserSignedIn:
            return "user_signed_in"
        }
    }

    var eventValue: String {
        switch self {
        case .isUserSignedIn(let isSignedIn):
            return isSignedIn.description
        }
    }
}
