import Models

public class MockWishListDependencyConainer: WishListDependencyContainerProtocol {
    public var wishListService: WishListServiceProtocol
    public var bagService: BagServiceProtocol

    public init(
        wishListService: WishListServiceProtocol = MockWishListService(),
        bagService: BagServiceProtocol = MockBagService()
    ) {
        self.wishListService = wishListService
        self.bagService = bagService
    }
}
