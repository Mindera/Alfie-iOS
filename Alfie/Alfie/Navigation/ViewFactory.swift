import Combine
import Core
import Model
import Navigation
import SharedUI
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
                HomeView(viewModel: HomeViewModel(sessionService: serviceProvider.sessionService))

            case .shop:
                let servicesViewModel = serviceProvider.configurationService.isFeatureEnabled(.storeServices)
                    ? WebViewModel(
                        webFeature: .storeServices,
                        dependencies: WebDependencyContainer(
                            deepLinkService: serviceProvider.deepLinkService,
                            webViewConfigurationService: serviceProvider.webViewConfigurationService,
                            webUrlProvider: serviceProvider.webUrlProvider
                        )
                    )
                    : nil

                ShopView(
                    categoriesViewModel: CategoriesViewModel(
                        navigationService: serviceProvider.navigationService,
                        showToolbar: false
                    ),
                    brandsViewModel: BrandsViewModel(brandsService: serviceProvider.brandsService),
                    servicesViewModel: servicesViewModel
                )

            case .wishlist:
                wishlistView
                    .withToolbar(for: .tab(.wishlist))

            case .bag:
                BagView(
                    viewModel: BagViewModel(
                        dependencies: BagDependencyContainer(
                            bagService: serviceProvider.bagService,
                            analytics: serviceProvider.analytics
                        )
                    )
                )
            }

        case .account:
            AccountView(
                viewModel: AccountViewModel(
                    configurationService: serviceProvider.configurationService,
                    sessionService: serviceProvider.sessionService
                )
            )

        case .search(let transition):
            let dependencies = SearchDependencyContainer(
                recentsService: serviceProvider.recentsService,
                searchService: serviceProvider.searchService,
                analytics: serviceProvider.analytics
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
                        wishlistService: serviceProvider.wishlistService,
                        analytics: serviceProvider.analytics
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
//            DebugMenuView(serviceProvider: serviceProvider)
            EmptyView()

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
            wishlistView
                .withToolbar(for: .wishlist)

        case .productDetails(let configuration):
            ProductDetailsView(
                viewModel: ProductDetailsViewModel(
                    configuration: configuration,
                    dependencies: ProductDetailsDependencyContainer(
                        productService: serviceProvider.productService,
                        webUrlProvider: serviceProvider.webUrlProvider,
                        bagService: serviceProvider.bagService,
                        wishlistService: serviceProvider.wishlistService,
                        configurationService: serviceProvider.configurationService,
                        analytics: serviceProvider.analytics
                    )
                )
            )

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
    var wishlistView: some View {
        WishlistView(
            viewModel: WishlistViewModel(
                dependencies: WishlistDependencyContainer(
                    wishlistService: serviceProvider.wishlistService,
                    bagService: serviceProvider.bagService,
                    analytics: serviceProvider.analytics
                )
            )
        )
    }
}
