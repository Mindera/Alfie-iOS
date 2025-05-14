import Foundation
import Model

public final class ProductListingDependencyContainer {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol
    let wishlistService: WishlistServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let configurationService: ConfigurationServiceProtocol

    public init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol,
        wishlistService: WishlistServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishlistService = wishlistService
        self.analytics = analytics
        self.configurationService = configurationService
    }
}
