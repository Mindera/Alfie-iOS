import Combine
import Core
import DeepLink
import Firebase
import Foundation
import Model
#if DEBUG
import Mocks
#endif
import Network
import Utils

final class ServiceProvider: ServiceProviderProtocol {
    let analytics: AlfieAnalyticsTracker
    let apiEndpointService: ApiEndpointServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    let deepLinkService: DeepLinkServiceProtocol
    let hapticsService: HapticsServiceProtocol
    let navigationService: NavigationServiceProtocol
    let recentsService: RecentsServiceProtocol?
    let reachabilityService: ReachabilityServiceProtocol
    let storageService: StorageServiceProtocol?
    let userDefaults: UserDefaultsProtocol
    let productService: ProductServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let notificationsService: NotificationsServiceProtocol
    let searchService: SearchServiceProtocol
    let webViewConfigurationService: WebViewConfigurationServiceProtocol
    let cartService: CartServiceProtocol
    let wishlistService: WishlistServiceProtocol
    let sessionService: SessionServiceProtocol

    private(set) var authenticationService: AuthenticationServiceProtocol

    private var subscriptions: Set<AnyCancellable> = []

    init() {
        self.userDefaults = UserDefaults.standard
        self.apiEndpointService = ApiEndpointService(appDelegate: AppDelegate.instance, userDefaults: userDefaults)
        self.webUrlProvider = WebURLProvider(host: ThemedURL.preferredHost, log: log)

        // Assuming Australia for now, to be revised later
        let defaultInitializationCountry = "AU"

        authenticationService = AuthenticationService()
        analytics = FirebaseAnalyticsTracker().eraseToAnyAnalyticsTracker()

        let firebaseProvider = FirebaseRemoteConfigurationProvider(
            minimumFetchInterval: ReleaseConfigurator.isDebug ? 30 : 1800,
            log: log
        )
        let localProvider = LocalConfigurationProvider()

        var providers: [ConfigurationProviderProtocol] = [firebaseProvider, localProvider] // Order matters!

        #if DEBUG
        providers.insert(DebugConfigurationProvider.shared, at: 0)
        #endif

        configurationService = ConfigurationService(
            providers: providers,
            authenticationService: authenticationService,
            country: defaultInitializationCountry
        )
        deepLinkService = DeepLinkService(configuration: LinkConfiguration(), log: log)
        hapticsService = HapticsService.instance
        reachabilityService = ReachabilityService(monitor: NWPathMonitor())
        storageService = StorageService()
        recentsService = RecentsService(
            autoSaveEnabled: false,
            storageService: storageService,
            storageKey: ThemedStorageKey.recentSearches.rawValue
        )

        // BFF API (GraphQL + REST)
        // Pass false if you wish to remove console clutter
        let restClient = NetworkClient(logRequests: true, logResponses: true, log: log)
        let bffErrorReporter = BFFErrorReporter(analytics: analytics, log: log)
        let bffDependencies = BFFClientDependencyContainer(
            reachabilityService: reachabilityService,
            restNetworkClient: restClient,
            errorReporter: bffErrorReporter
        )
        let apiUrl = apiEndpointService.apiEndpoint(for: apiEndpointService.currentApiEndpoint)
        log.debug("Initializing BFF API with endpoint \(apiUrl.absoluteString)")
        let bffClient = BFFClientService(
            url: apiUrl,
            logRequests: true, // Pass false if you wish to remove console clutter
            dependencies: bffDependencies,
            log: log
        )
        notificationsService = NotificationsService()

        // API Services
        navigationService = NavigationService(bffClient: bffClient)
        productService = ProductService(bffClient: bffClient)
        searchService = SearchService(bffClient: bffClient)
        webViewConfigurationService = WebViewConfigurationService(bffClient: bffClient, log: log)
        cartService = CartService(
            bffClient: bffClient,
            userDefaults: userDefaults,
            storageKey: StorageKey.cartId.rawValue
        )
        wishlistService = WishlistService(
            store: UserDefaultsStore(
                userDefaults: userDefaults,
                storageKey: StorageKey.wishlistItems.rawValue
            )
        )
        sessionService = SessionService(analytics: analytics)

        // A shared device must not hand the next shopper the previous one's bag. Wired here rather
        // than at the two sign-out buttons so a third one cannot forget to do it.
        //
        // `dropFirst` because the publisher replays its current value on subscribe: without it the
        // "signed out" every cold launch begins with would empty the bag before it was ever shown.
        sessionService.isUserSignedInPublisher
            .removeDuplicates()
            .dropFirst()
            .filter { !$0 }
            .sink { [cartService] _ in
                Task { await cartService.signOut() }
            }
            .store(in: &subscriptions)
    }

    public func resetServices() {
        // Break cyclic dependency: DeepLinkService -> DeepLinkHandler -> ThemedTabCoordinator -> ThemedViewFactory -> ServiceProvider -> DeepLinkService
        deepLinkService.update(handlers: [])
    }
}
