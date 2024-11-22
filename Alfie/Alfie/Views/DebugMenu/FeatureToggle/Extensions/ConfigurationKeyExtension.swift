import SwiftUI
import Models

extension ConfigurationKey {
    var localizedName: LocalizedStringResource {
        switch self {
        case .appUpdate:
            LocalizableFeatureToggle.appUpdateFeature
        case .wishlist:
            LocalizableFeatureToggle.wishlistFeature
        default:
            .init(stringLiteral: "")
        }
    }
}
