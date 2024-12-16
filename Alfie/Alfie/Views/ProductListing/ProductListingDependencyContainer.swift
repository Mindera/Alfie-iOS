import Foundation
import Models

final class ProductListingDependencyContainer: ProductListingDependencyContainerProtocol {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol
    let wishlistService: WishlistServiceProtocol

    init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol,
        wishlistService: WishlistServiceProtocol
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishlistService = wishlistService
    }
}
