import Foundation

public protocol WishListDependencyContainerProtocol {
    var wishListService: WishListServiceProtocol { get }
    var bagService: BagServiceProtocol { get }
}
