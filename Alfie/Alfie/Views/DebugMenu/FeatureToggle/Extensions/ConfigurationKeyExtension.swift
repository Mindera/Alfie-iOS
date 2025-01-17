import Models
import SwiftUI

extension ConfigurationKey {
    var localizedName: LocalizedStringResource {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .appUpdate:
            L10n.featureToggleAppUpdateOptionTitle
        case .wishlist:
            L10n.featureToggleWishlistOptionTitle
        case .custom:
            fatalError("Missing localisation key for custom feature")
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
