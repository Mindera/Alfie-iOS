import Core
import Models

final class WishListDependencyContainer: WishListDependencyContainerProtocol {
    let wishListService: WishListServiceProtocol
    let bagService: BagServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    init(
        wishListService: WishListServiceProtocol,
        bagService: BagServiceProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.wishListService = wishListService
        self.bagService = bagService
        self.configurationService = configurationService
    }
}
