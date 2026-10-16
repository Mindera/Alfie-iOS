import Model
import SharedUI

extension ProductDetailsViewErrorType {
    var title: String {
        switch self {
        case .generic, .notFound:
            return L10n.Pdp.ErrorView.title

        case .noConnection:
            return L10n.Pdp.ErrorView.NoConnection.title

        case .rateLimited:
            return L10n.Pdp.ErrorView.RateLimited.title

        case .serverError:
            return L10n.Pdp.ErrorView.ServerError.title
        }
    }

    var message: String {
        switch self {
        case .generic:
            return L10n.Pdp.ErrorView.Generic.message

        case .noConnection:
            return L10n.Pdp.ErrorView.NoConnection.message

        case .notFound:
            return L10n.Pdp.ErrorView.NotFound.message

        case .rateLimited:
            return L10n.Pdp.ErrorView.RateLimited.message

        case .serverError:
            return L10n.Pdp.ErrorView.ServerError.message
        }
    }
}
