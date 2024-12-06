import Foundation
import Models

final class ProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    let productService: ProductServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let bagService: BagServiceProtocol
    let wishListService: WishListServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    init(
        productService: ProductServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        bagService: BagServiceProtocol,
        wishListService: WishListServiceProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
        self.wishListService = wishListService
        self.configurationService = configurationService
    }
}
