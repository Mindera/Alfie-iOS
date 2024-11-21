import Common
import Core
import Firebase
import Foundation
import Models
#if DEBUG
import Mocks
#endif

final class ServiceProvider: ServiceProviderProtocol {
    let apiEndpointService: ApiEndpointServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    let deepLinkService: DeepLinkServiceProtocol
    let hapticsService: HapticsServiceProtocol
    let navigationService: NavigationServiceProtocol
    let recentsService: RecentsServiceProtocol?
    let reachabilityService: ReachabilityServiceProtocol
    let storageService: StorageServiceProtocol?
    let trackingService: TrackingServiceProtocol
    let userDefaults: UserDefaultsProtocol
    let productService: ProductServiceProtocol
    let brandsService: BrandsServiceProtocol
    let webUrlProvider: WebURLProviderProtocol
    let notificationsService: NotificationsServiceProtocol
    let searchService: SearchServiceProtocol
    let webViewConfigurationService: WebViewConfigurationServiceProtocol
    let bagService: BagServiceProtocol

    private(set) var authenticationService: AuthenticationServiceProtocol

    init() {
        self.userDefaults = UserDefaults.standard
        self.apiEndpointService = ApiEndpointService(appDelegate: AppDelegate.instance, userDefaults: userDefaults)
        self.webUrlProvider = WebURLProvider(host: ThemedURL.preferredHost)

        // Assuming Australia for now, to be revised later
        let defaultInitializationCountry = "AU"

        authenticationService = AuthenticationService()
        trackingService = TrackingService(providers: [FirebaseAnalyticsService()])

        let firebaseProvider = FirebaseRemoteConfigurationProvider(
            minimumFetchInterval: ReleaseConfigurator.isDebug ? 30 : 1800
        )
        let localProvider = LocalConfigurationProvider()
        configurationService = ConfigurationService(
            providers: [firebaseProvider, localProvider], // Order matters!
            authenticationService: authenticationService,
            country: defaultInitializationCountry
        )
        deepLinkService = DeepLinkService(configuration: LinkConfiguration())
        hapticsService = HapticsService.instance
        reachabilityService = ReachabilityService(monitor: ReachabilityMonitor())
        storageService = StorageService()
        recentsService = RecentsService(
            autoSaveEnabled: false,
            storageService: storageService,
            storageKey: ThemedStorageKey.recentSearches.rawValue
        )

        // BFF API (GraphQL + REST)
        // Pass false if you wish to remove console clutter
        let restClient = NetworkClient(logRequests: true, logResponses: true)
        let bffDependencies = BFFClientDependencyContainer(
            reachabilityService: reachabilityService,
            restNetworkClient: restClient
        )
        let apiUrl = apiEndpointService.apiEndpoint(for: apiEndpointService.currentApiEndpoint)
        log("Initializing BFF API with endpoint \(apiUrl.absoluteString)")
        let bffClient = BFFClientService(
            url: apiUrl,
            logRequests: true, // Pass false if you wish to remove console clutter
            dependencies: bffDependencies
        )
        notificationsService = NotificationsService()

        // API Services
        navigationService = NavigationService(bffClient: bffClient)
        productService = ProductService(bffClient: bffClient)
        brandsService = BrandsService(bffClient: bffClient)
        searchService = SearchService(bffClient: bffClient)
        webViewConfigurationService = WebViewConfigurationService(bffClient: bffClient)
        bagService = MockBagService()
    }

    public func resetServices() {
        // Break cyclic dependency: DeepLinkService -> DeepLinkHandler -> ThemedTabCoordinator -> ThemedViewFactory -> ServiceProvider -> DeepLinkService
        deepLinkService.update(handlers: [])
    }
}
