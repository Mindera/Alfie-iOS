import Foundation

public protocol ServiceProviderProtocol: AnyObject {
    var authenticationService: AuthenticationServiceProtocol { get }
    var configurationService: ConfigurationServiceProtocol { get }
    var deepLinkService: DeepLinkServiceProtocol { get }
    var trackingService: TrackingServiceProtocol { get }
    var apiEndpointService: ApiEndpointServiceProtocol { get }
    var hapticsService: HapticsServiceProtocol { get }
    var recentsService: RecentsServiceProtocol? { get }
    var reachabilityService: ReachabilityServiceProtocol { get }
    var storageService: StorageServiceProtocol? { get }
    var userDefaults: UserDefaultsProtocol { get }
    var webUrlProvider: WebURLProviderProtocol { get }
    var notificationsService: NotificationsServiceProtocol { get }
    var webViewConfigurationService: WebViewConfigurationServiceProtocol { get }

    // API
    var navigationService: NavigationServiceProtocol { get }
    var productService: ProductServiceProtocol { get }
    var brandsService: BrandsServiceProtocol { get }
    var searchService: SearchServiceProtocol { get }
    var bagService: BagServiceProtocol { get }
    var wishListService: WishListServiceProtocol { get }

    // Reset services before the app itself is reset, to allow them to cleanup gracefully if necessary
    func resetServices()
}
