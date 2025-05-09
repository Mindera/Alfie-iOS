import Combine
import Core
import Model
import MyAccount
import ProductDetails
import ProductListing
import Search
import SwiftUI
import Web
import Wishlist

public final class HomeFlowViewModel: ObservableObject {
    @Published var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    @Published private var isSearchPresented = false
    @Published public var overlayView: AnyView?
    private var subscriptions = Set<AnyCancellable>()
    @Namespace private var animation

    private lazy var searchFlowViewModel: SearchFlowViewModel = {
        SearchFlowViewModel(
            serviceProvider: serviceProvider,
            intentViewBuilder: { [weak self] in
                self?.searchIntentViewBuilder(for: $0) ?? AnyView(Text("Something went wrong"))
            },
            closeSearchAction: { [weak self] in self?.isSearchPresented = false }
        )
    }()

    public init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
        setupBindings()
    }

    private func setupBindings() {
        $isSearchPresented
            .sink { [weak self] isSearchPresented in
                guard let self else { return }

                if isSearchPresented {
                    overlayView = AnyView(
                        SearchFlowView(
                            viewModel: searchFlowViewModel,
                            transition: .matchedGeometryEffect(
                                id: Constants.searchBarGeometryID,
                                namespace: animation //
                            )
                        )
                    )
                } else {
                    overlayView = nil
                }
            }
            .store(in: &subscriptions)
    }

    func makeHomeViewModel() -> some HomeViewModelProtocol2 {
        HomeViewModel2(
            sessionService: serviceProvider.sessionService,
            navigate: { [weak self] route in self?.navigate(route) },
            showSearch: { [weak self] in self?.isSearchPresented = true }
        )
    }

    func makeAccountViewModel() -> some AccountViewModelProtocol2 {
        AccountViewModel2(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        ) { [weak self] in
            self?.navigate(.myAccount($0))
        }
    }

    func makeProductListingViewModel(
        configuration: ProductListingScreenConfiguration2
    ) -> some ProductListingViewModelProtocol2 {
        ProductListingViewModel2(
            dependencies: .init(
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
            openWebfeatureAction: { [weak self] in self?.navigate(.productListing(.productDetails(.webFeature($0)))) }
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

    private func navigate(_ route: HomeRoute) {
        path.append(route)
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        path.removeLast()
    }

    private func searchIntentViewBuilder(for intent: SearchIntent) -> AnyView {
        switch intent {
        case .productListing(let searchTerm, let category):
            AnyView(
                ProductListingView2(
                    viewModel: makeProductListingViewModelForSearch(searchTerm: searchTerm, category: category)
                )
            )

        case .productDetails(let productID, let product):
            AnyView(
                ProductDetailsView2(
                    viewModel: makeProductDetailsViewModelForSearch(productID: productID, product: product)
                )
            )

        case .webFeature(let feature):
            AnyView(
                WebView2(viewModel: makeWebViewModelForSearch(feature: feature))
            )
        }
    }

    private func makeProductListingViewModelForSearch(
        searchTerm: String?,
        category: String?
    ) -> some ProductListingViewModelProtocol2 {
        let configuration = ProductListingScreenConfiguration2(
            category: category,
            searchText: searchTerm,
            urlQueryParameters: nil,
            mode: .searchResults
        )

        return ProductListingViewModel2(
            dependencies: .init(
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
        ) { [weak self] route in
            switch route {
            case .productDetails(let productDetailsRoute):
                switch productDetailsRoute {
                case .productDetails(let productID, let product):
                    self?.searchFlowViewModel.navigate(
                        .searchIntent(.productDetails(productID: productID, product: product))
                    )

                case .webFeature(let feature):
                    self?.searchFlowViewModel.navigate(.searchIntent(.webFeature(feature)))
                }

            case .productListing(let configuration):
                self?.searchFlowViewModel.navigate(
                    .searchIntent(
                        .productListing(searchTerm: configuration.searchText, category: configuration.category)
                    )
                )

            case .search:
                self?.searchFlowViewModel.navigate(.search)
            }
        }
    }

    private func makeProductDetailsViewModelForSearch(
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
            goBackAction: { [weak self] in self?.searchFlowViewModel.pop() },
            openWebfeatureAction: { [weak self] in self?.searchFlowViewModel.navigate(.searchIntent(.webFeature($0))) }
        )
    }

    private func makeWebViewModelForSearch(feature: WebFeature) -> some WebViewModelProtocol2 {
        WebViewModel2(
            webFeature: feature,
            dependencies: WebDependencyContainer2(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            )
        )
    }

    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView {
        switch intent {
        case .wishlist:
            AnyView(
                WishlistView2(viewModel: makeWishlistViewModelForMyAccount())
            )
        }
    }

    func makeWishlistViewModelForMyAccount() -> some WishlistViewModelProtocol2 {
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

    private enum Constants {
        static let searchBarGeometryID = "SearchBar"
    }
}
