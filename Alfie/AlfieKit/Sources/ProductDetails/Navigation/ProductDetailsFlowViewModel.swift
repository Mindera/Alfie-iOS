import Model
import SwiftUI
import Web

public final class ProductDetailsFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = ProductDetailsRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    private let configuration: ProductDetailsConfiguration2

    public init(
        configuration: ProductDetailsConfiguration2,
        serviceProvider: ServiceProviderProtocol
    ) {
        self.configuration = configuration
        self.serviceProvider = serviceProvider
    }

    func makeProductDetailsViewModel() -> some ProductDetailsViewModelProtocol2 {
        ProductDetailsViewModel2(
            configuration: configuration,
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
        configuration: ProductDetailsConfiguration2
    ) -> some ProductDetailsViewModelProtocol2 {
        ProductDetailsViewModel2(
            configuration: configuration,
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
}
