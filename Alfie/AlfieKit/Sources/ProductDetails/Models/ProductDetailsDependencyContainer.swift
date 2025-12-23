import AlicerceLogging
import CombineSchedulers
import Foundation
import Model

public final class ProductDetailsDependencyContainer {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let productService: ProductServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let bagService: BagServiceProtocol
    let wishlistService: WishlistServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let log: Logger

    public init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        productService: ProductServiceProtocol,
        webUrlProvider: WebURLProviderProtocol,
        bagService: BagServiceProtocol,
        wishlistService: WishlistServiceProtocol,
        configurationService: ConfigurationServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        log: Logger
    ) {
        self.scheduler = scheduler
        self.productService = productService
        self.webUrlProvider = webUrlProvider
        self.bagService = bagService
        self.wishlistService = wishlistService
        self.configurationService = configurationService
        self.analytics = analytics
        self.log = log
    }
}
