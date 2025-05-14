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

    func makeBagViewModel() -> some BagViewModelProtocol2 {
        BagViewModel2(
            isWishlistEnabled: serviceProvider.configurationService.isFeatureEnabled(.wishlist),
            dependencies: BagDependencyContainer2(
                bagService: serviceProvider.bagService,
                analytics: serviceProvider.analytics
            )
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeAccountViewModel() -> some AccountViewModelProtocol2 {
        AccountViewModel2(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        ) { [weak self] in
            self?.navigate(.myAccount($0))
        }
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
            openWebfeatureAction: { [weak self] in self?.navigate(.productDetails(.webFeature($0))) }
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

    func makeWishlistViewModel() -> some WishlistViewModelProtocol2 {
        WishlistViewModel2(
            hasNavigationSeparator: true,
            dependencies: WishlistDependencyContainer2(
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
                WishlistView2(viewModel: makeWishlistViewModel())
            )
        }
    }
}
