import Foundation
import Models

final class ProductDetailsDependencyContainer {
    let productService: ProductServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let bagService: BagServiceProtocol
    let wishlistService: WishlistServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    let analytics: AlfieAnalyticsTracker

    init(
        productService: ProductServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        bagService: BagServiceProtocol,
        wishlistService: WishlistServiceProtocol,
        configurationService: ConfigurationServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
        self.wishlistService = wishlistService
        self.configurationService = configurationService
        self.analytics = analytics
    }
}
