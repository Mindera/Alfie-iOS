import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web
import Wishlist

public final class BagFlowViewModel: BagFlowViewModelProtocol {
    public typealias Route = BagRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol

    public init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    // MARK: - View Models for BagRoute

    public func makeBagViewModel() -> BagViewModel {
        BagViewModel(
            isWishlistEnabled: serviceProvider.configurationService.isFeatureEnabled(.wishlist),
            dependencies: BagDependencyContainer(
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

    public func makeWishlistViewModel() -> WishlistViewModel {
        WishlistViewModel(
            hasNavigationSeparator: true,
            dependencies: WishlistDependencyContainer(
                wishlistService: serviceProvider.wishlistService,
                bagService: serviceProvider.bagService,
                analytics: serviceProvider.analytics
            )
        ) { [weak self] in
            self?.navigate(.wishlist($0))
        }
    }

    // MARK: - View Models for MyAccountIntent

    public func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel())
            )
        }
    }

    // MARK: - FlowViewModelProtocol

    public func navigate(_ route: BagRoute) {
        if case .bag = route {
            popToRoot()
        } else {
            path.append(route)
        }
    }
}
