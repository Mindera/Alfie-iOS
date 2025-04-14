import AlicerceAnalytics
import Common
import Foundation
import Model

public final class MockServiceProvider: ServiceProviderProtocol {
    public var analytics: AlfieAnalyticsTracker
    public var authenticationService: AuthenticationServiceProtocol
    public var configurationService: ConfigurationServiceProtocol
    public var deepLinkService: DeepLinkServiceProtocol
    public var hapticsService: HapticsServiceProtocol
    public var apiEndpointService: ApiEndpointServiceProtocol
    public var reachabilityService: ReachabilityServiceProtocol
    public var navigationService: NavigationServiceProtocol
    public var recentsService: RecentsServiceProtocol?
    public var storageService: StorageServiceProtocol?
    public var userDefaults: UserDefaultsProtocol
    public var productService: ProductServiceProtocol
    public var brandsService: BrandsServiceProtocol
    public var webUrlProvider: WebURLProviderProtocol
    public var notificationsService: NotificationsServiceProtocol
    public var searchService: SearchServiceProtocol
    public var webViewConfigurationService: WebViewConfigurationServiceProtocol
    public var bagService: BagServiceProtocol
    public var wishlistService: WishlistServiceProtocol
    public var sessionService: SessionServiceProtocol

    public init(
        analytics: AlfieAnalyticsTracker = MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
        authenticationService: AuthenticationServiceProtocol = MockAuthenticationService(),
        configurationService: ConfigurationServiceProtocol = MockConfigurationService(),
        deepLinkService: DeepLinkServiceProtocol = MockDeepLinkService(),
        apiEndpointService: ApiEndpointServiceProtocol = MockApiEndpointService(),
        hapticsService: HapticsServiceProtocol = MockHapticsService(),
        reachabilityService: ReachabilityServiceProtocol = MockReachabilityService(),
        navigationService: NavigationServiceProtocol = MockNavigationService(),
        recentsService: RecentsServiceProtocol = MockRecentsService(),
        storageService: StorageServiceProtocol? = MockStorageService(),
        userDefaults: UserDefaultsProtocol = MockUserDefaults(),
        productService: ProductServiceProtocol = MockProductService(),
        brandsService: BrandsServiceProtocol = MockBrandsService(),
        webUrlProvider: WebURLProviderProtocol = MockWebUrlProvider(),
        notificationsService: NotificationsServiceProtocol = MockNotificationsServiceProtocol(),
        searchService: SearchServiceProtocol = MockSearchService(),
        webViewConfigurationService: WebViewConfigurationServiceProtocol = MockWebViewConfigurationService(),
        bagService: BagServiceProtocol = MockBagService(),
        wishlistService: WishlistServiceProtocol = MockWishlistService(),
        sessionService: SessionServiceProtocol = MockSessionService()
    ) {
        self.analytics = analytics
        self.authenticationService = authenticationService
        self.configurationService = configurationService
        self.deepLinkService = deepLinkService
        self.apiEndpointService = apiEndpointService
        self.hapticsService = hapticsService
        self.reachabilityService = reachabilityService
        self.navigationService = navigationService
        self.recentsService = recentsService
        self.storageService = storageService
        self.userDefaults = userDefaults
        self.productService = productService
        self.brandsService = brandsService
        self.webUrlProvider = webUrlProvider
        self.notificationsService = notificationsService
        self.searchService = searchService
        self.webViewConfigurationService = webViewConfigurationService
        self.bagService = bagService
        self.wishlistService = wishlistService
        self.sessionService = sessionService
    }

    public var onResetServicesCalled: (() -> Void)?
    public func resetServices() {
        onResetServicesCalled?()
    }
}
