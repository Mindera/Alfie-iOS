import Core
import Models

final class WishlistDependencyContainer {
    let wishlistService: WishlistServiceProtocol
    let bagService: BagServiceProtocol

    init(wishlistService: WishlistServiceProtocol, bagService: BagServiceProtocol) {
        self.wishlistService = wishlistService
        self.bagService = bagService
    }
}
