import Bag
import CategorySelector
import Combine
import Core
import Foundation
import Home
import Model
import MyAccount
import OrderedCollections
import ProductDetails
import ProductListing
import Search
import Utils
import Web
import Wishlist

public final class AppFeatureViewModel: AppFeatureViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol

    @Published public private(set) var currentScreen: AppStartupScreen = .loading
    public let rootTabViewModel: RootTabViewModel<
        BagFlowViewModel,
        CategorySelectorFlowViewModel,
        HomeFlowViewModel,
        WishlistFlowViewModel
    >
    public let appUpdateInfoConfiguration: AppUpdateInfo?
    // CurrentValueSubject because if using @Published, the publisher will emit a new value a bit before the property is updated, leading to some nasty bugs on appStartupScreenCondition
    private var isLoading: CurrentValueSubject<Bool, Never> = .init(true)
    private var didFindError: CurrentValueSubject<Bool, Never> = .init(false)
    private var subscriptions = Set<AnyCancellable>()
    private var appStartupScreenCondition: OrderedDictionary<AppStartupScreen, Bool> {
        [
            .loading: self.isLoading.value,
            .error: self.didFindError.value,
            .forceUpdate: self.configurationService.isForceAppUpdateAvailable,
            .landing: true,
        ]
    }

    private var prioritisedScreen: AppStartupScreen {
        appStartupScreenCondition.first { $0.value }?.key ?? .error
    }

    public init(
        serviceProvider: ServiceProviderProtocol,
        startupCompletionDelay: CGFloat = 2
    ) {
        self.configurationService = serviceProvider.configurationService

        var tabs: [Model.Tab] = [.home, .shop, .bag]

        if serviceProvider.configurationService.isFeatureEnabled(.wishlist) {
            tabs.insert(.wishlist, at: 2)
        }

        let bagDependencyContainer = BagDependencyContainer(
            bagService: serviceProvider.bagService,
            configurationService: serviceProvider.configurationService,
            analytics: serviceProvider.analytics
        )
        let myAccountDependencyContainer = MyAccountDependencyContainer(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService
        )
        let productDetailsDependencyContainer = ProductDetailsDependencyContainer(
            productService: serviceProvider.productService,
            webUrlProvider: serviceProvider.webUrlProvider,
            bagService: serviceProvider.bagService,
            wishlistService: serviceProvider.wishlistService,
            configurationService: serviceProvider.configurationService,
            analytics: serviceProvider.analytics
        )
        let webDependencyContainer = WebDependencyContainer(
            deepLinkService: serviceProvider.deepLinkService,
            webViewConfigurationService: serviceProvider.webViewConfigurationService,
            webUrlProvider: serviceProvider.webUrlProvider
        )
        let wishlistDependencyContainer = WishlistDependencyContainer(
            wishlistService: serviceProvider.wishlistService,
            bagService: serviceProvider.bagService,
            analytics: serviceProvider.analytics
        )
        let categorySelectorDependencyContainer = CategorySelectorDependencyContainer(
            navigationService: serviceProvider.navigationService,
            brandsService: serviceProvider.brandsService,
            configurationService: serviceProvider.configurationService
        )
        let productListingDependencyContainer = ProductListingDependencyContainer(
            productListingService: ProductListingService(
                productService: serviceProvider.productService,
                configuration: .init(type: .plp)
            ),
            plpStyleListProvider: ProductListingStyleProvider(userDefaults: serviceProvider.userDefaults),
            wishlistService: serviceProvider.wishlistService,
            analytics: serviceProvider.analytics,
            configurationService: serviceProvider.configurationService
        )
        let searchDependencyContainer = SearchDependencyContainer(
            recentsService: serviceProvider.recentsService,
            searchService: serviceProvider.searchService,
            analytics: serviceProvider.analytics
        )
        let homeDependencyContainer = HomeDependencyContainer(
            configurationService: serviceProvider.configurationService,
            apiEndpointService: serviceProvider.apiEndpointService,
            sessionService: serviceProvider.sessionService
        )

        let bagFlowViewModel = BagFlowViewModel(
            dependencies: .init(
                bagDependencyContainer: bagDependencyContainer,
                myAccountDependencyContainer: myAccountDependencyContainer,
                productDetailsDependencyContainer: productDetailsDependencyContainer,
                webDependencyContainer: webDependencyContainer,
                wishlistDependencyContainer: wishlistDependencyContainer
            )
        )
        let categorySelectorFlowViewModel = CategorySelectorFlowViewModel(
            dependencies: .init(
                categorySelectorDependencyContainer: categorySelectorDependencyContainer,
                webDependencyContainer: webDependencyContainer,
                myAccountDependencyContainer: myAccountDependencyContainer,
                productDetailsDependencyContainer: productDetailsDependencyContainer,
                productListingDependencyContainer: productListingDependencyContainer,
                wishlistDependencyContainer: wishlistDependencyContainer,
                searchDependencyContainer: searchDependencyContainer
            )
        )
        let homeFlowViewModel = HomeFlowViewModel(
            dependencies: .init(
                homeDependencyContainer: homeDependencyContainer,
                myAccountDependencyContainer: myAccountDependencyContainer,
                productListingDependencyContainer: productListingDependencyContainer,
                productDetailsDependencyContainer: productDetailsDependencyContainer,
                webDependencyContainer: webDependencyContainer,
                wishlistDependencyContainer: wishlistDependencyContainer,
                searchDependencyContainer: searchDependencyContainer
            )
        )
        let wishlistFlowViewModel = WishlistFlowViewModel(
            dependencies: .init(
                wishlistDependencyContainer: wishlistDependencyContainer,
                myAccountDependencyContainer: myAccountDependencyContainer,
                productDetailsDependencyContainer: productDetailsDependencyContainer,
                webDependencyContainer: webDependencyContainer
            )
        )

        self.rootTabViewModel = RootTabViewModel(
            tabs: tabs,
            initialTab: .home,
            serviceProvider: serviceProvider,
            bagFlowViewModel: bagFlowViewModel,
            categorySelectorFlowViewModel: categorySelectorFlowViewModel,
            homeFlowViewModel: homeFlowViewModel,
            wishlistFlowViewModel: wishlistFlowViewModel
        )

        self.appUpdateInfoConfiguration = serviceProvider.configurationService.forceAppUpdateInfo

        setupSubscriptions()
        WebViewPreload.preloadWebView()

        DispatchQueue.main.asyncAfter(deadline: .now() + startupCompletionDelay) {
            self.isLoading.send(false)
        }
    }

    private func setupSubscriptions() {
        Publishers.Merge(didFindError, isLoading)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.currentScreen = self.prioritisedScreen
            }
            .store(in: &subscriptions)
    }

    public func navigate(for deepLinkType: DeepLink.LinkType) {
        switch deepLinkType {
        case .home:
            rootTabViewModel.navigate(.home(.home))

        case .shop(let route):
            switch route {
            case ThemedURL.brands.path:
                rootTabViewModel.navigate(.shop(.categorySelector(.brands)))

            case ThemedURL.services.path:
                rootTabViewModel.navigate(.shop(.categorySelector(.services)))

            default:
                rootTabViewModel.navigate(.shop(.categorySelector(.categories)))
            }

        case .bag:
            rootTabViewModel.navigate(.bag(.bag))

        case .wishlist:
            rootTabViewModel.navigate(.wishlist(.wishlist))

        case .account:
            rootTabViewModel.navigate(.home(.myAccount(.myAccount)))

        case .productList(let paths, let searchText, let urlQueryParameters):
            rootTabViewModel.navigate(
                .shop(
                    .productListing(
                        .productListing(.init(
                            category: paths,
                            searchText: searchText,
                            urlQueryParameters: urlQueryParameters,
                            mode: .listing
                        ))
                    )
                )
            )

        case .productDetail(let productId, _, _, _):
            // TODO: currently the API does not support fetching a product by the StyleNumber (that is parsed from the URL), just by ProductID, so all requests will return "not found"
            rootTabViewModel.navigate(.shop(.productDetails(.productDetails(.id(productId)))))

        case .webView(let url):
            rootTabViewModel.navigate(.shop(.web(url: url, title: "")))

        case .unknown:
            return
        }
    }
}
