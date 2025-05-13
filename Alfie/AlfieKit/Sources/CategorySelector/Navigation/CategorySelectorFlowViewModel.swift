import Core
import Model
import MyAccount
import ProductDetails
import ProductListing
import SwiftUI
import Web
import Wishlist

public final class CategorySelectorFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol

    public init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    var isWishlistEnabled: Bool {
        serviceProvider.configurationService.isFeatureEnabled(.wishlist)
    }

    func makeCategoriesViewModel() -> some CategoriesViewModelProtocol {
        CategoriesViewModel2(
            navigationService: serviceProvider.navigationService,
            showToolbar: false,
            ignoreLocalNavigation: true
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeBrandsViewModel() -> some BrandsViewModelProtocol {
        BrandsViewModel2(brandsService: serviceProvider.brandsService) { [weak self] in
            self?.navigate($0)
        }
    }

    var isStoreServicesEnabled: Bool {
        serviceProvider.configurationService.isFeatureEnabled(.storeServices)
    }

    func makeServicesViewModel() -> some WebViewModelProtocol2 {
        WebViewModel2(
            webFeature: .storeServices,
            dependencies: WebDependencyContainer2(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            )
        )
    }

    func makeSubCategoriesViewModel(
        subCategories: [NavigationItem],
        parent: NavigationItem
    ) -> some CategoriesViewModelProtocol {
        // Initialize the categories view model to ignore local links (i.e. Shop tab links like Brands and Services)
        // as those will be handled by the view directly
        CategoriesViewModel2(
            categories: subCategories,
            title: parent.title,
            showToolbar: true,
            ignoreLocalNavigation: false
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

    func makeProductListingViewModel(
        configuration: ProductListingScreenConfiguration2
    ) -> some ProductListingViewModelProtocol2 {
        ProductListingViewModel2(
            dependencies: ProductListingDependencyContainer2(
                productListingService: ProductListingService(
                    productService: serviceProvider.productService,
                    configuration: .init(type: .plp)
                ),
                plpStyleListProvider: ProductListingStyleProvider2(userDefaults: serviceProvider.userDefaults),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics
            ),
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode
        ) { [weak self] in
            self?.navigate(.productListing($0))
        }
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

    func makeURLWebViewModel(url: URL, title: String) -> some WebViewModelProtocol2 {
        WebViewModel2(
            url: url,
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

    func navigate(_ route: CategorySelectorRoute) {
        path.append(route)
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    public func pop() {
        path.removeLast()
    }
}
