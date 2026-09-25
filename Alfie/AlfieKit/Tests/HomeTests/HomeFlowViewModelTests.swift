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
    private var overlays: [TabOverlay?]!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        serviceProvider = MockServiceProvider()
        overlays = []
        subscriptions = []
        sut = HomeFlowViewModel(dependencies: Self.makeDependencies(serviceProvider: serviceProvider))
        sut.overlayPublisher
            .sink { [weak self] in self?.overlays.append($0) }
            .store(in: &subscriptions)
    }

    override func tearDownWithError() throws {
        subscriptions = nil
        overlays = nil
        sut = nil
        serviceProvider = nil
        try super.tearDownWithError()
    }

    func test_overlay_before_any_presentation_is_nil() {
        XCTAssertEqual(overlays.count, 1)
        XCTAssertNil(overlays.last ?? nil)
    }

    func test_did_tap_scan_on_home_presents_an_overlay() {
        sut.makeHomeViewModel().didTapScan()

        XCTAssertNotNil(overlays.last ?? nil)
    }

    func test_did_tap_search_on_home_presents_an_overlay() {
        sut.makeHomeViewModel().didTapSearch()

        XCTAssertNotNil(overlays.last ?? nil)
    }

    func test_did_tap_search_on_home_keeps_the_tab_bar() {
        sut.makeHomeViewModel().didTapSearch()

        XCTAssertEqual(overlays.last??.hidesTabBar, false)
    }

    func test_did_tap_scan_on_home_hides_the_tab_bar() {
        sut.makeHomeViewModel().didTapScan()

        XCTAssertEqual(overlays.last??.hidesTabBar, true)
    }

    func test_dismiss_overlay_while_search_is_presented_clears_the_overlay() {
        sut.makeHomeViewModel().didTapSearch()

        sut.dismissOverlay()

        XCTAssertNil(overlays.last ?? nil)
    }

    /// Presenting one overlay and then the other replaces it rather than stacking: `overlay` holds a
    /// single value, so the scanner cannot open behind the search screen.
    func test_did_tap_scan_while_search_is_presented_replaces_the_overlay() {
        let homeViewModel = sut.makeHomeViewModel()
        homeViewModel.didTapSearch()

        homeViewModel.didTapScan()

        XCTAssertNotNil(overlays.last ?? nil)
        // One emission for the initial nil, then one per presentation — never two live at once.
        XCTAssertEqual(overlays.count, 3)
    }

    // MARK: - Search results

    /// A listing showing search results keeps its own way back to search, and that way back is the
    /// tab's overlay — the same single value the scanner uses. Every listing builder hands over the
    /// same `showSearchOverlay`, including the one reached only through `SearchFlowViewModel`, so
    /// driving the public builder covers that one too.
    func test_did_tap_search_on_a_search_results_listing_presents_an_overlay() {
        let listing = sut.makeProductListingViewModel(
            configuration: ProductListingScreenConfiguration(
                category: nil,
                searchText: "jeans",
                urlQueryParameters: nil,
                mode: .searchResults
            )
        )

        listing.didTapSearch()

        XCTAssertNotNil(overlays.last ?? nil)
    }

    // MARK: - Helpers

    private static func makeDependencies(serviceProvider: MockServiceProvider) -> HomeFlowDependencyContainer {
        let log = MockLogger()

        return HomeFlowDependencyContainer(
            homeDependencyContainer: HomeDependencyContainer(
                configurationService: serviceProvider.configurationService,
                apiEndpointService: serviceProvider.apiEndpointService,
                bffApiKeyService: serviceProvider.bffApiKeyService,
                sessionService: serviceProvider.sessionService
            ),
            myAccountDependencyContainer: MyAccountDependencyContainer(
                configurationService: serviceProvider.configurationService,
                sessionService: serviceProvider.sessionService,
                makeSettingsView: { _ in AnyView(EmptyView()) }
            ),
            productListingDependencyContainer: ProductListingDependencyContainer(
                productListingService: MockProductListingService(),
                plpStyleListProvider: MockProductListingStyleProvider(),
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
                productService: serviceProvider.productService,
                makeScanService: { MockCameraScanService() },
                analytics: serviceProvider.analytics,
                haptics: serviceProvider.hapticsService,
                log: log
            )
        )
    }
}
