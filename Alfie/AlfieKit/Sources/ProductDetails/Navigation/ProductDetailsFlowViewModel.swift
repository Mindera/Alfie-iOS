import Model
import SwiftUI
import Web

public final class ProductDetailsFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = ProductDetailsRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    private let configuration: ProductDetailsConfiguration

    public init(
        configuration: ProductDetailsConfiguration,
        serviceProvider: ServiceProviderProtocol
    ) {
        self.configuration = configuration
        self.serviceProvider = serviceProvider
    }

    // MARK: - View Models for ProductDetailsRoute

    func makeProductDetailsViewModel() -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
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
        configuration: ProductDetailsConfiguration
    ) -> some ProductDetailsViewModelProtocol {
        ProductDetailsViewModel(
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

    func makeWebViewModel(feature: WebFeature) -> some WebViewModelProtocol {
        WebViewModel(
            webFeature: feature,
            dependencies: WebDependencyContainer(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            )
        )
    }
}
