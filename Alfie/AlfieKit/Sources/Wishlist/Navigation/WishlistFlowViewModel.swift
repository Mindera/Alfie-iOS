import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web

public final class WishlistFlowViewModel: WishlistFlowViewModelProtocol {
    public typealias Route = WishlistRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol

    public init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    // MARK: - View Models for WishlistRoute

    public func makeWishlistViewModel(isRoot: Bool) -> WishlistViewModel {
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

    public func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        ) { [weak self] in
            self?.navigate(.myAccount($0))
        }
    }

    public func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel {
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

    public func makeWebViewModel(feature: WebFeature) -> WebViewModel {
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

    public func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel(isRoot: false))
            )
        }
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: WishlistRoute) {
        if case .wishlist = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
