import Bag
import CategorySelector
import Combine
import Foundation
import Home
import Model
import OrderedCollections
import Utils
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

        let bagFlowViewModel = BagFlowViewModel(
            serviceProvider: serviceProvider
        )
        let categorySelectorFlowViewModel = CategorySelectorFlowViewModel(
            serviceProvider: serviceProvider
        )
        let homeFlowViewModel = HomeFlowViewModel(
            serviceProvider: serviceProvider
        )
        let wishlistFlowViewModel = WishlistFlowViewModel(
            serviceProvider: serviceProvider
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
