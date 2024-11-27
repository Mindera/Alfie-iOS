import Models
import SwiftUI

extension ConfigurationKey {
    var localizedName: LocalizedStringResource {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .appUpdate:
            LocalizableFeatureToggle.appUpdateFeature
        case .wishlist:
            LocalizableFeatureToggle.wishlistFeature
        case .custom:
            fatalError("Missing localisation key for custom feature")
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
