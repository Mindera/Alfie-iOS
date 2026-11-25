import Mocks
import Model
import ProductDetails
import ProductListing
import Scanner
import Search
import TestUtils
import Web
import XCTest
@testable import TabFlow

final class TabOverlayCoordinatorTests: XCTestCase {
    private var mockProductListing: MockProductListingService!
    private var sut: TabOverlayCoordinator!

    override func setUp() {
        super.setUp()
        mockProductListing = MockProductListingService()
        sut = TabOverlayCoordinator(dependencies: makeDependencies())
    }

    override func tearDown() {
        sut = nil
        mockProductListing = nil
        super.tearDown()
    }

    func test_brand_listing_shows_search_results_for_the_brand_pinned_to_its_key() {
        var searches: [BrandSearch] = []
        mockProductListing.onSearchPageCalled = { searchTerm, _, _, filters in
            searches.append(.init(searchTerm: searchTerm, brandNames: filters?.brandNames))
            return .fixture(products: Array(Product.fixtures.prefix(2)))
        }
        let viewModel = sut.makeBrandListingViewModel(brand: .fixture(key: "acme-key", name: "Acme"))

        XCTAssertEmitsValue(from: viewModel.$state, afterTrigger: { viewModel.viewDidAppear() })

        XCTAssertEqual(searches, [.init(searchTerm: "", brandNames: ["acme-key"])])
        XCTAssertEqual(viewModel.searchTerm, "Acme")
        XCTAssertTrue(viewModel.isBrandListing)
        XCTAssertFalse(viewModel.showSearchButton)
    }

    private func makeDependencies() -> TabOverlayDependencyContainer {
        let serviceProvider = MockServiceProvider()
        let log = MockLogger()

        return TabOverlayDependencyContainer(
            search: SearchDependencyContainer(
                recentsService: serviceProvider.recentsService,
                searchService: serviceProvider.searchService,
                analytics: serviceProvider.analytics,
                log: log
            ),
            scanner: ScannerDependencyContainer(
                deepLinkService: serviceProvider.deepLinkService,
                productService: serviceProvider.productService,
                makeScanService: { MockCameraScanService() },
                analytics: serviceProvider.analytics,
                haptics: serviceProvider.hapticsService,
                log: log
            ),
            productListing: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: MockProductListingStyleProvider(),
                wishlistService: serviceProvider.wishlistService,
                analytics: serviceProvider.analytics,
                configurationService: serviceProvider.configurationService,
                log: log
            ),
            productDetails: ProductDetailsDependencyContainer(
                productService: serviceProvider.productService,
                webUrlProvider: serviceProvider.webUrlProvider,
                cartService: serviceProvider.cartService,
                wishlistService: serviceProvider.wishlistService,
                configurationService: serviceProvider.configurationService,
                analytics: serviceProvider.analytics,
                log: log
            ),
            web: WebDependencyContainer(
                deepLinkService: serviceProvider.deepLinkService,
                webViewConfigurationService: serviceProvider.webViewConfigurationService,
                webUrlProvider: serviceProvider.webUrlProvider
            )
        )
    }
}

private struct BrandSearch: Equatable {
    let searchTerm: String
    let brandNames: [String]?
}
