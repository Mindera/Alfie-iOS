import Foundation
import Model

final class ProductListingDependencyContainer {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol
    let wishlistService: WishlistServiceProtocol
    let analytics: AlfieAnalyticsTracker

    init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol,
        wishlistService: WishlistServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishlistService = wishlistService
        self.analytics = analytics
    }
}
