import Model
import SharedUI

extension ProductListingTransientError {
    var message: String {
        switch (error, request) {
        case (.serverError, _):
            return L10n.Plp.TransientError.ServerError.message

        case (.rateLimited, _):
            return L10n.Plp.TransientError.RateLimited.message

        case (.noConnection, _):
            return L10n.Plp.TransientError.NoConnection.message

        case (.generic, .nextPage), (.noResults, .nextPage):
            return L10n.Plp.NextPage.errorMessage

        case (.generic, .refresh), (.noResults, .refresh):
            return L10n.Plp.Refresh.errorMessage
        }
    }
}
