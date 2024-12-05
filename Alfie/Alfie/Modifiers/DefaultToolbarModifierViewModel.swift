import Models

struct DefaultToolbarModifierViewModel: DefaultToolbarModifierViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol

    var isWishlistEnabled: Bool {
        configurationService.isFeatureEnabled(.wishlist)
    }

    init(configurationService: ConfigurationServiceProtocol) {
        self.configurationService = configurationService
    }
}
