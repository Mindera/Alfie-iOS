import Foundation

public protocol ProductListingDependencyContainerProtocol {
    var productListingService: ProductListingServiceProtocol { get }
    var plpStyleListProvider: ProductListingStyleProviderProtocol { get }
    var wishlistService: WishlistServiceProtocol { get }
}
