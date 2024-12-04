import Combine
import Core
import Models
import Navigation
import StyleGuide
import SwiftUI

final class ViewFactory: ViewFactoryProtocol {
    // Must be weak to avoid a cyclic dependency
    private weak var serviceProvider: ServiceProviderProtocol! // swiftlint:disable:this implicitly_unwrapped_optional

    init() {
        fatalError("Use the init(serviceProvider:) version instead")
    }

    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    @ViewBuilder
    func view(for screen: Screen) -> some View {
        switch screen {
        case .tab(let tab):
            switch tab {
            case .home:
                HomeView(viewFactory: self)

            case .shop:
                ShopView(
                    categoriesViewModel: CategoriesViewModel(
                        navigationService: serviceProvider.navigationService,
                        showToolbar: false
                    ),
                    brandsViewModel: BrandsViewModel(brandsService: serviceProvider.brandsService),
                    servicesViewModel: WebViewModel(
                        webFeature: .storeServices,
                        dependencies: WebDependencyContainer(
                            deepLinkService: serviceProvider.deepLinkService,
                            webViewConfigurationService: serviceProvider.webViewConfigurationService,
                            webUrlProvider: serviceProvider.webUrlProvider
                        )
                    )
                )

            case .wishlist:
                wishListView

            case .bag:
                BagView(
                    viewModel: BagViewModel(
                        dependencies: BagDependencyContainer(bagService: serviceProvider.bagService)
                    )
                )
            }

        case .account:
            AccountView(viewModel: AccountViewModel(configurationService: serviceProvider.configurationService))

        case .search(let transition):
            let dependencies = SearchDependencyContainer(
                recentsService: serviceProvider.recentsService,
                searchService: serviceProvider.searchService
            )
            let viewModel = SearchViewModel(dependencies: dependencies)
            SearchView(viewModel: viewModel, transition: transition)

        case .productListing(let configuration):
            ProductListingView(
                viewModel: ProductListingViewModel(
                    dependencies: ProductListingDependencyContainer(
                        productListingService: ProductListingService(
                            productService: serviceProvider.productService,
                            configuration: .init(type: .plp)
                        ),
                        plpStyleListProvider: ProductListingStyleProvider(userDefaults: serviceProvider.userDefaults),
                        wishListService: serviceProvider.wishListService
                    ),
                    category: configuration.category,
                    searchText: configuration.searchText,
                    urlQueryParameters: configuration.urlQueryParameters,
                    mode: configuration.mode
                )
            )

        case .forceAppUpdate:
            if let configuration = serviceProvider.configurationService.forceAppUpdateInfo {
                ForceAppUpdateView(configuration: configuration)
            }

        case .debugMenu:
            DebugMenuView(serviceProvider: serviceProvider)

        case .webView(let url, _):
            WebView(
                viewModel: WebViewModel(
                    url: url,
                    dependencies: WebDependencyContainer(
                        deepLinkService: serviceProvider.deepLinkService,
                        webViewConfigurationService: serviceProvider.webViewConfigurationService,
                        webUrlProvider: serviceProvider.webUrlProvider
                    )
                )
            )
            .withToolbar(for: screen)

        case .webFeature(let feature):
            WebView(
                viewModel: WebViewModel(
                    webFeature: feature,
                    dependencies: WebDependencyContainer(
                        deepLinkService: serviceProvider.deepLinkService,
                        webViewConfigurationService: serviceProvider.webViewConfigurationService,
                        webUrlProvider: serviceProvider.webUrlProvider
                    )
                )
            )
            .withToolbar(for: screen)

        case .wishlist:
            wishListView

        case .productDetails(let type):
            switch type {
            case .id(let id):
                ProductDetailsView(
                    viewModel: ProductDetailsViewModel(
                        productId: id,
                        product: nil,
                        dependencies: ProductDetailsDependencyContainer(
                            productService: serviceProvider.productService,
                            webUrlProvider: serviceProvider.webUrlProvider,
                            bagService: serviceProvider.bagService,
                            wishListService: serviceProvider.wishListService
                        )
                    )
                )

            case .product(let product):
                ProductDetailsView(
                    viewModel: ProductDetailsViewModel(
                        productId: product.id,
                        product: product,
                        dependencies: ProductDetailsDependencyContainer(
                            productService: serviceProvider.productService,
                            webUrlProvider: serviceProvider.webUrlProvider,
                            bagService: serviceProvider.bagService,
                            wishListService: serviceProvider.wishListService
                        )
                    )
                )
            }

        case .recentSearches:
            let viewModel = RecentSearchesViewModel(recentsService: serviceProvider.recentsService)
            RecentSearchesView(viewModel: viewModel)

        case .categoryList(let categories, let title):
            let viewModel = CategoriesViewModel(categories: categories, title: title, showToolbar: true)
            CategoriesView(viewModel: viewModel)
        }
    }
}

private extension ViewFactory {
    var wishListView: some View {
        WishListView(
            viewModel: WishListViewModel(
                dependencies: WishListDependencyContainer(
                    wishListService: serviceProvider.wishListService,
                    bagService: serviceProvider.bagService
                )
            )
        )
    }
}
