import Combine
import Model
import MyAccount
import ProductDetails
import ProductListing
import Scanner
import Search
import SwiftUI
import Web
import Wishlist
import XCTest
@testable import Home
@testable import Mocks

/// The tab's overlay, which is how the scanner and the search screen are both presented.
///
/// Worth testing rather than trusting: `overlay` is a single value, so the two screens share one
/// writer, and a scan that fails to clear it would leave the flow believing the scanner was still
/// up and refusing to present it again.
final class HomeFlowViewModelTests: XCTestCase {
    private var serviceProvider: MockServiceProvider!
    private var sut: HomeFlowViewModel!
    private var overlayViews: [AnyView?]!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        serviceProvider = MockServiceProvider()
        overlayViews = []
        subscriptions = []
        sut = HomeFlowViewModel(dependencies: Self.makeDependencies(serviceProvider: serviceProvider))
        sut.overlayViewPublisher
            .sink { [weak self] in self?.overlayViews.append($0) }
            .store(in: &subscriptions)
    }

    override func tearDownWithError() throws {
        subscriptions = nil
        overlayViews = nil
        sut = nil
        serviceProvider = nil
        try super.tearDownWithError()
    }

    func test_theTabHasNoOverlayUntilSomethingAsksForOne() {
        XCTAssertEqual(overlayViews.count, 1)
        XCTAssertNil(overlayViews.last ?? nil)
    }

    func test_tappingScanPresentsTheScanner() {
        sut.makeHomeViewModel().didTapScan()

        XCTAssertNotNil(overlayViews.last ?? nil)
    }

    func test_tappingSearchPresentsAnOverlayToo() {
        sut.makeHomeViewModel().didTapSearch()

        XCTAssertNotNil(overlayViews.last ?? nil)
    }

    /// Presenting one overlay and then the other replaces it rather than stacking: `overlay` holds a
    /// single value, so the scanner cannot open behind the search screen.
    func test_askingForASecondOverlayReplacesTheFirst() {
        let homeViewModel = sut.makeHomeViewModel()

        homeViewModel.didTapSearch()
        homeViewModel.didTapScan()

        XCTAssertNotNil(overlayViews.last ?? nil)
        // One emission for the initial nil, then one per presentation — never two live at once.
        XCTAssertEqual(overlayViews.count, 3)
    }

    // MARK: - Helpers

    private static func makeDependencies(serviceProvider: MockServiceProvider) -> HomeFlowDependencyContainer {
        let log = MockLogger()

        return HomeFlowDependencyContainer(
            homeDependencyContainer: HomeDependencyContainer(
                configurationService: serviceProvider.configurationService,
                apiEndpointService: serviceProvider.apiEndpointService,
                sessionService: serviceProvider.sessionService
            ),
            myAccountDependencyContainer: MyAccountDependencyContainer(
                configurationService: serviceProvider.configurationService,
                sessionService: serviceProvider.sessionService,
                makeSettingsView: { _ in AnyView(EmptyView()) }
            ),
            productListingDependencyContainer: ProductListingDependencyContainer(
                productListingService: MockProductListingService(),
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: serviceProvider.userDefaults),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics,
                configurationService: serviceProvider.configurationService,
                log: log
            ),
            productDetailsDependencyContainer: ProductDetailsDependencyContainer(
                productService: serviceProvider.productService,
                webUrlProvider: serviceProvider.webUrlProvider,
                cartService: serviceProvider.cartService,
                wishlistService: serviceProvider.wishlistService,
                configurationService: serviceProvider.configurationService,
                analytics: serviceProvider.analytics,
                log: log
            ),
            webDependencyContainer: WebDependencyContainer(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            ),
            wishlistDependencyContainer: WishlistDependencyContainer(
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics
            ),
            searchDependencyContainer: SearchDependencyContainer(
                recentsService: serviceProvider.recentsService,
                analytics: serviceProvider.analytics,
                log: log
            ),
            scannerDependencyContainer: ScannerDependencyContainer(
                deepLinkService: serviceProvider.deepLinkService,
                makeScanService: { MockCameraScanService() },
                log: log
            ),
            deepLinkService: serviceProvider.deepLinkService
        )
    }
}
