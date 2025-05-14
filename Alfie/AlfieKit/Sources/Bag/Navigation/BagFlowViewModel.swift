import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web
import Wishlist

public final class BagFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = BagRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol

    public init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    func makeBagViewModel() -> some BagViewModelProtocol {
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

    func makeWishlistViewModel() -> some WishlistViewModelProtocol {
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

    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView(viewModel: makeWishlistViewModel())
            )
        }
    }
}
