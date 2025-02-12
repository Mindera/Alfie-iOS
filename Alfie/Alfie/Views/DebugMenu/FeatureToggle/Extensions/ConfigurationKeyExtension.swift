import Models
import SwiftUI

extension ConfigurationKey {
    var localizedName: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .appUpdate:
            L10n.FeatureToggle.AppUpdate.Option.title
        case .wishlist:
            L10n.FeatureToggle.Wishlist.Option.title
        case .custom:
            fatalError("Missing localisation key for custom feature")
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
