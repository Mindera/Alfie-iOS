import Foundation

public protocol ProductListingDependencyContainerProtocol {
    var productListingService: ProductListingServiceProtocol { get }
    var plpStyleListProvider: ProductListingStyleProviderProtocol { get }
    var wishListService: WishListServiceProtocol { get }
    var configurationService: ConfigurationServiceProtocol { get }
}
