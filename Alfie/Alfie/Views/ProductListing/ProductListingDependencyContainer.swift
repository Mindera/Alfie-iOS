import Foundation
import Models

final class ProductListingDependencyContainer: ProductListingDependencyContainerProtocol {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol
    let wishListService: WishListServiceProtocol

    init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol,
        wishListService: WishListServiceProtocol
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishListService = wishListService
    }
}
