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

public final class CategorySelectorFlowViewModel: ObservableObject, FlowViewModelProtocol {
    public typealias Route = CategorySelectorRoute
    @Published public var path = NavigationPath()
    private let serviceProvider: ServiceProviderProtocol
    @Published private var isSearchPresented = false
    @Published public var overlayView: AnyView?
    private var subscriptions = Set<AnyCancellable>()

    var isWishlistEnabled: Bool {
        serviceProvider.configurationService.isFeatureEnabled(.wishlist)
    }

    var isStoreServicesEnabled: Bool {
        serviceProvider.configurationService.isFeatureEnabled(.storeServices)
    }

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
                    overlayView = AnyView(SearchFlowView(viewModel: searchFlowViewModel))
                } else {
                    overlayView = nil
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - View Models for CategorySelectorRoute

    func makeCategoriesViewModel() -> some CategoriesViewModelProtocol {
        CategoriesViewModel(
            navigationService: serviceProvider.navigationService,
            showToolbar: false,
            ignoreLocalNavigation: true
        ) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeBrandsViewModel() -> some BrandsViewModelProtocol {
        BrandsViewModel(brandsService: serviceProvider.brandsService) { [weak self] in
            self?.navigate($0)
        }
    }

    func makeServicesViewModel() -> some WebViewModelProtocol {
        WebViewModel(
            webFeature: .storeServices,
            dependencies: WebDependencyContainer(
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
        CategoriesViewModel(
            categories: subCategories,
            title: parent.title,
            showToolbar: true,
            ignoreLocalNavigation: false
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

    func makeProductListingViewModel(
        configuration: ProductListingScreenConfiguration
    ) -> some ProductListingViewModelProtocol {
        ProductListingViewModel(
            dependencies: ProductListingDependencyContainer(
                productListingService: ProductListingService(
                    productService: serviceProvider.productService,
                    configuration: .init(type: .plp)
                ),
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: serviceProvider.userDefaults),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics,
                configurationService: serviceProvider.configurationService
            ),
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode,
            navigate: { [weak self] in self?.navigate(.productListing($0)) },
            showSearch: { [weak self] in self?.isSearchPresented = true }
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

    func makeURLWebViewModel(url: URL, title: String) -> some WebViewModelProtocol {
        WebViewModel(
            url: url,
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

    // MARK: - View Models for SearchIntent

    private func searchIntentViewBuilder(for intent: SearchIntent) -> AnyView {
        switch intent {
        case .productListing(let searchTerm, let category):
            return AnyView(
                ProductListingView(
                    viewModel: makeProductListingViewModelForSearch(searchTerm: searchTerm, category: category)
                )
            )

        case .productDetails(let productID, let product):
            let configuration: ProductDetailsConfiguration
            if let product {
                configuration = .product(product)
            } else {
                configuration = .id(productID)
            }

            return AnyView(
                ProductDetailsView(
                    viewModel: makeProductDetailsViewModelForSearch(configuration: configuration)
                )
            )

        case .webFeature(let feature):
            return AnyView(
                WebView(viewModel: makeWebViewModelForSearch(feature: feature))
                    .toolbarView(title: feature.title)
            )
        }
    }

    private func makeProductListingViewModelForSearch(
        searchTerm: String?,
        category: String?
    ) -> some ProductListingViewModelProtocol {
        let configuration = ProductListingScreenConfiguration(
            category: category,
            searchText: searchTerm,
            urlQueryParameters: nil,
            mode: .searchResults
        )

        return ProductListingViewModel(
            dependencies: .init(
                productListingService: ProductListingService(
                    productService: serviceProvider.productService,
                    configuration: .init(type: .plp)
                ),
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: serviceProvider.userDefaults),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics,
                configurationService: serviceProvider.configurationService
            ),
            category: configuration.category,
            searchText: configuration.searchText,
            urlQueryParameters: configuration.urlQueryParameters,
            mode: configuration.mode,
            navigate: { [weak self] route in
                switch route {
                case .productDetails(let productDetailsRoute):
                    let productID: String
                    let product: Product?

                    switch productDetailsRoute {
                    case .productDetails(let configuration):
                        switch configuration {
                        case .id(let configurationProductID):
                            productID = configurationProductID
                            product = nil

                        case .product(let configurationProduct):
                            productID = configurationProduct.id
                            product = configurationProduct

                        case .selectedProduct(let selectedProduct):
                            productID = selectedProduct.product.id
                            product = selectedProduct.product
                        }

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
                }
            },
            showSearch: { [weak self] in self?.isSearchPresented = true }
        )
    }

    private func makeProductDetailsViewModelForSearch(
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
            goBackAction: { [weak self] in self?.searchFlowViewModel.pop() },
            openWebfeatureAction: { [weak self] in self?.searchFlowViewModel.navigate(.searchIntent(.webFeature($0))) }
        )
    }

    private func makeWebViewModelForSearch(feature: WebFeature) -> some WebViewModelProtocol {
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
                WishlistView(viewModel: makeWishlistViewModel())
            )
        }
    }
}
