import Foundation

public protocol WishlistDependencyContainerProtocol {
    var wishlistService: WishlistServiceProtocol { get }
    var bagService: BagServiceProtocol { get }
}
