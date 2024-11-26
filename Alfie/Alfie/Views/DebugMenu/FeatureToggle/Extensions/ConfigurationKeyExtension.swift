import Models
import SwiftUI

extension ConfigurationKey {
    var localizedName: LocalizedStringResource {
        switch self {
        case .appUpdate:
            LocalizableFeatureToggle.appUpdateFeature
        case .wishlist:
            LocalizableFeatureToggle.wishlistFeature
        case .custom(_):
            fatalError("Missing localisation key for custom feature")
        }
    }
}
