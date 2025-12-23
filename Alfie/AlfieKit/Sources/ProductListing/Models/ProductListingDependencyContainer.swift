import AlicerceLogging
import Foundation
import Model

public final class ProductListingDependencyContainer {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol
    let wishlistService: WishlistServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let configurationService: ConfigurationServiceProtocol
    let log: Logger

    public init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol,
        wishlistService: WishlistServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        configurationService: ConfigurationServiceProtocol,
        log: Logger
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishlistService = wishlistService
        self.analytics = analytics
        self.configurationService = configurationService
        self.log = log
    }
}
