import Model
import SwiftUI
import Web

public final class ProductDetailsFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    private let productId: String
    private let product: Product?

    public init(
        productId: String,
        product: Product?,
        serviceProvider: ServiceProviderProtocol
    ) {
        self.productId = productId
        self.product = product
        self.serviceProvider = serviceProvider
    }

    func makeProductDetailsViewModel() -> some ProductDetailsViewModelProtocol2 {
        ProductDetailsViewModel2(
            productId: productId,
            product: product,
            dependencies: .init(
                productService: serviceProvider.productService,
                webUrlProvider: serviceProvider.webUrlProvider,
                bagService: serviceProvider.bagService,
                wishlistService: serviceProvider.wishlistService,
                configurationService: serviceProvider.configurationService,
                analytics: serviceProvider.analytics
            ),
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.webFeature($0)) }
        )
    }

    func makeProductDetailsViewModel(
        productID: String,
        product: Product?
    ) -> some ProductDetailsViewModelProtocol2 {
        ProductDetailsViewModel2(
            productId: productID,
            product: product,
            dependencies: .init(
                productService: serviceProvider.productService,
                webUrlProvider: serviceProvider.webUrlProvider,
                bagService: serviceProvider.bagService,
                wishlistService: serviceProvider.wishlistService,
                configurationService: serviceProvider.configurationService,
                analytics: serviceProvider.analytics
            ),
            goBackAction: { [weak self] in self?.pop() },
            openWebfeatureAction: { [weak self] in self?.navigate(.webFeature($0)) }
        )
    }

    func makeWebViewModel(feature: WebFeature) -> some WebViewModelProtocol2 {
        WebViewModel2(
            webFeature: feature,
            dependencies: WebDependencyContainer2(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            )
        )
    }

    private func navigate(_ route: ProductDetailsRoute) {
        path.append(route)
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    private func pop() {
        path.removeLast()
    }
}
