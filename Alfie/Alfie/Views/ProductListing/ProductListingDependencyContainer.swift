import Foundation
import Models

final class ProductListingDependencyContainer: ProductListingDependencyContainerProtocol {
    let productListingService: ProductListingServiceProtocol
    let plpStyleListProvider: ProductListingStyleProviderProtocol
    let wishListService: WishListServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    init(
        productListingService: ProductListingServiceProtocol,
        plpStyleListProvider: ProductListingStyleProviderProtocol,
        wishListService: WishListServiceProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.productListingService = productListingService
        self.plpStyleListProvider = plpStyleListProvider
        self.wishListService = wishListService
        self.configurationService = configurationService
    }
}
