import Core
import Models

final class WishListDependencyContainer: WishListDependencyContainerProtocol {
    let wishListService: WishListServiceProtocol
    let bagService: BagServiceProtocol

    init(
        wishListService: WishListServiceProtocol,
        bagService: BagServiceProtocol
    ) {
        self.wishListService = wishListService
        self.bagService = bagService
    }
}
