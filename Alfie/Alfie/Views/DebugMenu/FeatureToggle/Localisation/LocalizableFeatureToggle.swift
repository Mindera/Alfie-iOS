import Foundation

struct LocalizableFeatureToggle: LocalizableProtocol {
    @LocalizableResource<Self>(.title) static var title
    @LocalizableResource<Self>(.debugConfigurationEnabled) static var debugConfigurationEnabled
    @LocalizableResource<Self>(.wishlistFeature) static var wishlistFeature
    @LocalizableResource<Self>(.appUpdateFeature) static var appUpdateFeature
    
    enum Keys: String, LocalizableKeyProtocol {
        case title = "KeyFeatureToggle"
        case debugConfigurationEnabled = "KeyDebugConfigurationEnabled"
        case wishlistFeature = "KeyWishlistFeature"
        case appUpdateFeature = "KeyAppUpdateFeature"
    }
}
