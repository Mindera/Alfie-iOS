import Foundation
import Models

final class ProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    let productService: ProductServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let bagService: BagServiceProtocol
    let wishListService: WishListServiceProtocol

    init(
        productService: ProductServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        bagService: BagServiceProtocol,
        wishListService: WishListServiceProtocol
    ) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
        self.wishListService = wishListService
    }
}
