import Model
import SharedUI

extension FailureKind {
    var lookupFailedNotice: String {
        switch self {
        case .noConnection:
            return L10n.Scanner.LookupFailed.NoConnection.message

        case .rateLimited:
            return L10n.Scanner.LookupFailed.RateLimited.message

        case .serverError:
            return L10n.Scanner.LookupFailed.ServerError.message

        case .generic:
            return L10n.Scanner.LookupFailed.message
        }
    }
}
