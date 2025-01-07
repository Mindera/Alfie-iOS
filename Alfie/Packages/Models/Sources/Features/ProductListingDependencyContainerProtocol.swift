import Foundation

// swiftlint:disable:next type_name
public protocol ProductListingDependencyContainerProtocol {
    var productListingService: ProductListingServiceProtocol { get }
    var plpStyleListProvider: ProductListingStyleProviderProtocol { get }
    var wishlistService: WishlistServiceProtocol { get }
}
