import Combine
import Mocks
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
@testable import CategorySelector

final class CategorySelectorFlowViewModelTests: XCTestCase {
    private var sut: CategorySelectorFlowViewModel!
    private var overlayViews: [AnyView?]!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        overlayViews = []
        subscriptions = []
        sut = CategorySelectorFlowViewModel(dependencies: Self.makeDependencies(serviceProvider: MockServiceProvider()))
        sut.overlayViewPublisher
            .sink { [weak self] in self?.overlayViews.append($0) }
            .store(in: &subscriptions)
    }

    override func tearDownWithError() throws {
        subscriptions = nil
        overlayViews = nil
        sut = nil
        try super.tearDownWithError()
    }

    func test_overlay_before_any_presentation_is_nil() {
        XCTAssertEqual(overlayViews.count, 1)
        XCTAssertNil(overlayViews.last ?? nil)
    }

    func test_present_scanner_with_no_overlay_emits_an_overlay() {
        sut.presentScanner()

        XCTAssertEqual(overlayViews.count, 2)
        XCTAssertNotNil(overlayViews.last ?? nil)
    }

    func test_present_scanner_while_search_is_presented_replaces_the_overlay() {
        sut.presentSearch()

        sut.presentScanner()

        XCTAssertEqual(overlayViews.count, 3)
        XCTAssertNotNil(overlayViews.last ?? nil)
    }

    // MARK: - Helpers

    private static func makeDependencies(serviceProvider: MockServiceProvider) -> CategorySelectorFlowDependencyContainer {
        let log = MockLogger()

        return CategorySelectorFlowDependencyContainer(
            categorySelectorDependencyContainer: CategorySelectorDependencyContainer(
                navigationService: MockNavigationService(),
                configurationService: serviceProvider.configurationService
            ),
            webDependencyContainer: WebDependencyContainer(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            ),
            myAccountDependencyContainer: MyAccountDependencyContainer(
                configurationService: serviceProvider.configurationService,
                sessionService: serviceProvider.sessionService,
                makeSettingsView: { _ in AnyView(EmptyView()) }
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
            productListingDependencyContainer: ProductListingDependencyContainer(
                productListingService: MockProductListingService(),
                plpStyleListProvider: MockProductListingStyleProvider(),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics,
                configurationService: serviceProvider.configurationService,
                log: log
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
                analytics: serviceProvider.analytics,
                haptics: serviceProvider.hapticsService,
                log: log
            ),
            log: log
        )
    }
}
