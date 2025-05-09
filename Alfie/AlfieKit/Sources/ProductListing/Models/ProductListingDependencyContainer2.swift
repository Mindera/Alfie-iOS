import Foundation
import Model

public final class ProductListingDependencyContainer2 {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol2
    let wishlistService: WishlistServiceProtocol
    let analytics: AlfieAnalyticsTracker

    public init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol2,
        wishlistService: WishlistServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishlistService = wishlistService
        self.analytics = analytics
    }
}
