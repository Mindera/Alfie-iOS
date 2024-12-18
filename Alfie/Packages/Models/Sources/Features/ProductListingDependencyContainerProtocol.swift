import Foundation

// swiftlint:disable:next type_name
public protocol ProductListingDependencyContainerProtocol {
    var productListingService: ProductListingServiceProtocol { get }
    var plpStyleListProvider: ProductListingStyleProviderProtocol { get }
    var wishListService: WishListServiceProtocol { get }
}
