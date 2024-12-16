import Foundation
import Models

final class ProductDetailsDependencyContainer: ProductDetailsDependencyContainerProtocol {
    let productService: ProductServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let bagService: BagServiceProtocol
    let wishlistService: WishlistServiceProtocol
    let configurationService: ConfigurationServiceProtocol

    init(
        productService: ProductServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        bagService: BagServiceProtocol,
        wishlistService: WishlistServiceProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
        self.wishlistService = wishlistService
        self.configurationService = configurationService
    }
}
