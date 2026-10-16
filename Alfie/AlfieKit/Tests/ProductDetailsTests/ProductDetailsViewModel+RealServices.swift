import Core
import Mocks
import Model
@testable import ProductDetails

extension ProductDetailsViewModel {
    static func onRealServices(bffClient: MockBFFClientService) -> ProductDetailsViewModel {
        .init(
            configuration: .id("the-handle"),
            dependencies: ProductDetailsDependencyContainer(
                scheduler: .immediate,
                productService: ProductService(bffClient: bffClient),
                webUrlProvider: MockWebUrlProvider(),
                cartService: MockCartService(),
                wishlistService: MockWishlistService(),
                configurationService: MockConfigurationService(),
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                log: MockLogger()
            ),
            goBackAction: {},
            openWebfeatureAction: { _ in },
            openProductAction: { _ in }
        )
    }
}
