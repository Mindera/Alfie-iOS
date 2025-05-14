import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web

public final class WishlistFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = WishlistRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol

    public init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    // MARK: - View Models for WishlistRoute

    func makeWishlistViewModel(isRoot: Bool) -> some WishlistViewModelProtocol {
        WishlistViewModel(
            hasNavigationSeparator: !isRoot,
            dependencies: WishlistDependencyContainer(
                wishlistService: serviceProvider.wishlistService,
                bagService: serviceProvider.bagService,
                analytics: serviceProvider.analytics
            )
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeAccountViewModel() -> some AccountViewModelProtocol {
        AccountViewModel(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        ) { [weak self] in
            self?.navigate(.myAccount($0))
        }
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
            openWebfeatureAction: { [weak self] in self?.navigate(.productDetails(.webFeature($0))) }
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

    // MARK: - View Models for MyAccountIntent

    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel(isRoot: false))
            )
        }
    }
}
