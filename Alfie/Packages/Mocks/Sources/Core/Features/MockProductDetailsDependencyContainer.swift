import Foundation
import Models

public class MockProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    public var productService: ProductServiceProtocol
    public var webUrlProvider: WebURLProviderProtocol
    public var bagService: BagServiceProtocol
    public var wishListService: WishListServiceProtocol

    public init(
        productService: ProductServiceProtocol = MockProductService(),
        webUrlProvider: WebURLProviderProtocol = MockWebUrlProvider(),
        bagService: BagServiceProtocol = MockBagService(),
        wishListService: WishListServiceProtocol = MockWishListService()
    ) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
        self.wishListService = wishListService
    }
}
