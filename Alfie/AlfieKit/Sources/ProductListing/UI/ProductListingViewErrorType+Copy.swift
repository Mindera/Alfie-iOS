import Model
import SharedUI

extension ProductListingViewErrorType {
    var title: String {
        switch self {
        case .generic, .noResults:
            return L10n.Plp.ErrorView.title

        case .noConnection:
            return L10n.Plp.ErrorView.NoConnection.title

        case .rateLimited:
            return L10n.Plp.ErrorView.RateLimited.title

        case .serverError:
            return L10n.Plp.ErrorView.ServerError.title
        }
    }

    var message: String {
        switch self {
        case .generic, .noResults:
            return L10n.Plp.ErrorView.message

        case .noConnection:
            return L10n.Plp.ErrorView.NoConnection.message

        case .rateLimited:
            return L10n.Plp.ErrorView.RateLimited.message

        case .serverError:
            return L10n.Plp.ErrorView.ServerError.message
        }
    }
}
