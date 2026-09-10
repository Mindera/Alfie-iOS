import AlicerceLogging
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
import Scanner
import Search
import SwiftUI
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
        log: Logger,
        startupCompletionDelay: CGFloat = 2
    ) {
        self.configurationService = serviceProvider.configurationService

        var tabs: [Model.Tab] = [.home, .shop, .bag]

        if serviceProvider.configurationService.isFeatureEnabled(.wishlist) {
            tabs.insert(.wishlist, at: 2)
        }

        tabs.append(.account)

        let bagDependencyContainer = BagDependencyContainer(
            cartService: serviceProvider.cartService,
            configurationService: serviceProvider.configurationService,
            analytics: serviceProvider.analytics,
            log: log
        )
        let myAccountDependencyContainer = MyAccountDependencyContainer(
            configurationService: serviceProvider.configurationService,
            sessionService: serviceProvider.sessionService,
            makeSettingsView: { [
                configurationService = serviceProvider.configurationService,
                apiEndpointService = serviceProvider.apiEndpointService
            ] present in
                SettingsViewFactory.make(
                    configurationService: configurationService,
                    apiEndpointService: apiEndpointService,
                    present: present
                )
            }
        )
        let productDetailsDependencyContainer = ProductDetailsDependencyContainer(
            productService: serviceProvider.productService,
            webUrlProvider: serviceProvider.webUrlProvider,
            cartService: serviceProvider.cartService,
            wishlistService: serviceProvider.wishlistService,
            configurationService: serviceProvider.configurationService,
            analytics: serviceProvider.analytics,
            log: log
        )
        let webDependencyContainer = WebDependencyContainer(
            deepLinkService: serviceProvider.deepLinkService,
            webViewConfigurationService: serviceProvider.webViewConfigurationService,
            webUrlProvider: serviceProvider.webUrlProvider
        )
        let wishlistDependencyContainer = WishlistDependencyContainer(
            wishlistService: serviceProvider.wishlistService,
            analytics: serviceProvider.analytics
        )
        let categorySelectorDependencyContainer = CategorySelectorDependencyContainer(
            navigationService: serviceProvider.navigationService,
            configurationService: serviceProvider.configurationService
        )
        let productListingDependencyContainer = ProductListingDependencyContainer(
            productListingService: ProductListingService(
                productService: serviceProvider.productService,
                searchService: serviceProvider.searchService,
                configuration: .init(type: .plp)
            ),
            plpStyleListProvider: ProductListingStyleProvider(userDefaults: serviceProvider.userDefaults),
            wishlistService: serviceProvider.wishlistService,
            analytics: serviceProvider.analytics,
            configurationService: serviceProvider.configurationService,
            log: log
        )
        // The scanner routes through the deep-link service rather than a route of its own, so that
        // service plus a camera is the whole of its wiring. A fresh scan service per presentation:
        // each one owns a camera session that is released with the screen that opened it.
        let scannerDependencyContainer = ScannerDependencyContainer(
            deepLinkService: serviceProvider.deepLinkService,
            makeScanService: { CameraScanService() },
            log: log
        )
        let searchDependencyContainer = SearchDependencyContainer(
            recentsService: serviceProvider.recentsService,
            analytics: serviceProvider.analytics,
            log: log
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
                searchDependencyContainer: searchDependencyContainer,
                log: log
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
                searchDependencyContainer: searchDependencyContainer,
                scannerDependencyContainer: scannerDependencyContainer,
                deepLinkService: serviceProvider.deepLinkService
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
        // Account tab reuses the existing MyAccount flow. Tapping Wishlist routes to the dedicated
        // Wishlist tab (wired via onSelectWishlist below), so the intent view is never rendered here.
        let myAccountFlowViewModel = MyAccountFlowViewModel(
            dependencies: MyAccountFlowDependencyContainer(myAccountDependencyContainer: myAccountDependencyContainer)
        ) { intent in
            switch intent {
            case .wishlist:
                return AnyView(EmptyView())
            }
        }

        self.rootTabViewModel = RootTabViewModel(
            tabs: tabs,
            initialTab: .home,
            serviceProvider: serviceProvider,
            bagFlowViewModel: bagFlowViewModel,
            categorySelectorFlowViewModel: categorySelectorFlowViewModel,
            homeFlowViewModel: homeFlowViewModel,
            wishlistFlowViewModel: wishlistFlowViewModel,
            myAccountFlowViewModel: myAccountFlowViewModel
        )

        self.appUpdateInfoConfiguration = serviceProvider.configurationService.forceAppUpdateInfo

        myAccountFlowViewModel.onSelectWishlist = { [weak self] in
            self?.rootTabViewModel.navigate(.wishlist(.wishlist))
        }

        setupSubscriptions()
        discardCartOnSignOut(
            sessionService: serviceProvider.sessionService,
            cartService: serviceProvider.cartService
        )
        loadStoredCartAtLaunch(cartService: serviceProvider.cartService)
        WebViewPreload.preloadWebView {
            log.debug("Preloaded WebView")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + startupCompletionDelay) {
            self.isLoading.send(false)
        }
    }

    /// A shared device must not hand the next shopper the previous one's bag. Wired once here rather
    /// than at each sign-out button so a third one cannot forget to do it.
    ///
    /// `dropFirst` because the publisher replays its current value on subscribe: without it the
    /// "signed out" every cold launch begins with would empty the bag before it was ever shown.
    private func discardCartOnSignOut(
        sessionService: SessionServiceProtocol,
        cartService: CartServiceProtocol
    ) {
        sessionService.isUserSignedInPublisher
            .removeDuplicates()
            .dropFirst()
            .filter { !$0 }
            .sink { _ in
                Task { await cartService.discardCart() }
            }
            .store(in: &subscriptions)
    }

    /// Reads the cart the last session left behind, so the bag tab's badge is right before the
    /// shopper goes looking. The cart id outlives the process in `UserDefaults` but the cart it
    /// names does not, so without this a shopper who adds items, kills the app and comes back sees
    /// no badge until they open the Bag tab — the one screen that already shows them the count.
    ///
    /// Costs nothing when there is no stored id: `fetch()` publishes `nil` without asking the
    /// server. A failure is dropped rather than surfaced — startup is the wrong moment to raise it,
    /// and the bag screen's own fetch reports it when the shopper actually goes to the bag.
    private func loadStoredCartAtLaunch(cartService: CartServiceProtocol) {
        Task { try? await cartService.fetch() }
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

    /// A link that names no destination is ignored, leaving the app where it stands. Which link
    /// leads where is `TabRoute.init(deepLinkType:)`.
    public func navigate(for deepLinkType: DeepLink.LinkType) {
        guard let route = TabRoute(deepLinkType: deepLinkType) else {
            return
        }

        rootTabViewModel.navigate(route)
    }
}
