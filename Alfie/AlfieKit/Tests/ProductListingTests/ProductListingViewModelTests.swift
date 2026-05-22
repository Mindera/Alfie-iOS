import AlicerceLogging
import Mocks
import Model
import TestUtils
import XCTest
@testable import ProductListing

final class ProductListingViewModelTests: XCTestCase {
    private var sut: ProductListingViewModel!
    private var mockProductListing: MockProductListingService!
    private var mockWishlistService: MockWishlistService!
    private let log = Log.DummyLogger()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockProductListing = MockProductListingService()
        mockWishlistService = MockWishlistService()
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            navigate: { _ in },
            showSearch: {}
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockProductListing = nil
        mockWishlistService = nil
        try super.tearDownWithError()
    }

    // MARK: - Wishlist heart toggle

    func test_isFavoriteState_returnsTrue_whenProductIsInWishlist() {
        let productId = "product-1"
        let blueVariant = Product.Variant.fixture(colour: .fixture(id: "blue", name: "Blue"))
        let redVariant = Product.Variant.fixture(colour: .fixture(id: "red", name: "Red"))
        let product = Product.fixture(id: productId, defaultVariant: redVariant, variants: [blueVariant, redVariant])
        // Match by product id, regardless of which variant happens to be stored.
        let service = MockWishlistService(products: [SelectedProduct(product: product, selectedVariant: blueVariant)])
        sut = makeSUT(wishlistService: service)
        let viewModel = sut!

        // `wishlistContent` is hydrated asynchronously on appear.
        XCTAssertEmitsValue(from: viewModel.$wishlistContent, where: { !$0.isEmpty }, afterTrigger: { viewModel.viewDidAppear() })

        XCTAssertTrue(viewModel.isFavoriteState(for: product))
    }

    func test_didTapAddToWishlist_whenUntoggling_removesProductFromWishlist() {
        let productId = "product-1"
        let blueVariant = Product.Variant.fixture(colour: .fixture(id: "blue", name: "Blue"))
        let redVariant = Product.Variant.fixture(colour: .fixture(id: "red", name: "Red"))
        let product = Product.fixture(id: productId, defaultVariant: redVariant, variants: [blueVariant, redVariant])
        // Defensive: pre-load multiple entries to confirm every row sharing the product id is removed.
        let service = MockWishlistService(products: [
            SelectedProduct(product: product, selectedVariant: blueVariant),
            SelectedProduct(product: product, selectedVariant: redVariant)
        ])
        sut = makeSUT(wishlistService: service)
        let viewModel = sut!

        XCTAssertEmitsValue(
            from: viewModel.$wishlistContent,
            where: { $0.isEmpty },
            afterTrigger: { viewModel.didTapAddToWishlist(for: product, isFavorite: true) }
        )
    }

    func test_didTapAddToWishlist_whenUntoggling_doesNotAffectOtherProducts() {
        let otherProduct = Product.fixture(id: "other")
        let targetProduct = Product.fixture(id: "target")
        let service = MockWishlistService(products: [
            SelectedProduct(product: otherProduct),
            SelectedProduct(product: targetProduct)
        ])
        sut = makeSUT(wishlistService: service)
        let viewModel = sut!

        XCTAssertEmitsValue(
            from: viewModel.$wishlistContent,
            where: { $0.count == 1 },
            afterTrigger: { viewModel.didTapAddToWishlist(for: targetProduct, isFavorite: true) }
        )

        XCTAssertEqual(viewModel.wishlistContent.first?.product.id, "other")
    }

    private func makeSUT(wishlistService: WishlistServiceProtocol? = nil) -> ProductListingViewModel {
        .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: wishlistService ?? mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            navigate: { _ in },
            showSearch: {}
        )
    }

    func test_loading_first_page_shows_skeleton_items() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            urlQueryParameters: ["category": "women/clothing"],
            skeletonItemsSize: 2,
            navigate: { _ in },
            showSearch: {}
        )

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.state.value?.title, "")
        XCTAssertEqual(sut.state.value?.products.count, 2)
    }

    func test_fetch_first_page_with_filter_params_on_landing() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            sort: "sort",
            urlQueryParameters: ["category": "women/clothing"],
            navigate: { _ in },
            showSearch: {}
        )

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.title, "")

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query, sort in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "women/clothing")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.title, "Women's Clothing")
        XCTAssertEqual(sut.totalNumberOfProducts, 5)
    }

    func test_fetch_first_page_with_searctText_on_landing() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            searchText: "something",
            sort: "sort",
            navigate: { _ in },
            showSearch: {}
        )

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.title, "")

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query, sort in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.title, "Women's Clothing")
        XCTAssertEqual(sut.totalNumberOfProducts, 5)
    }

    func test_fetch_first_page_failure_returns_error() {
        mockProductListing.onPageCalled = { categoryId, query, sort in
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query, sort: sort)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }

    func test_fetch_next_page_with_filter_params_when_displays_last_item() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            sort: "sort",
            urlQueryParameters: ["category": "women/clothing"],
            navigate: { _ in },
            showSearch: {}
        )

        mockProductListing.onPageCalled = { _, _, _ in
            ProductListing.fixture(pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                                   products: Product.fixtures)
        }

        mockProductListing.onHasNextCalled = { true }
        mockProductListing.onNextCalled = { categoryId, query, sort in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "women/clothing")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(products: Product.fixtures)
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.didDisplay(Product.fixtures.last!) })

        XCTAssertTrue(sut.state.isLoadingNextPage)
    }

    func test_does_not_fetch_next_page_when_no_next_page() {
        mockProductListing.onHasNextCalled = { false }
        mockProductListing.onPageCalled = { _, _, _ in
            ProductListing.fixture(products: Product.fixtures)
        }

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.sut.didDisplay(Product.fixtures.last!) })
    }

    func test_does_not_fetch_next_page_while_displaying_products() {
        guard let penultimateProduct = Product.fixtures[safe: Product.fixtures.count - 2] else {
            return
        }
        mockProductListing.onHasNextCalled = { false }
        mockProductListing.onPageCalled = { _, _, _ in
            ProductListing.fixture(products: Product.fixtures)
        }

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.sut.didDisplay(penultimateProduct) })
    }

    func test_allows_showing_search_if_not_loading_and_not_showing_search_results() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            searchText: "something",
            sort: "sort",
            mode: .listing,
            navigate: { _ in },
            showSearch: {}
        )

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query, sort in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertTrue(sut.showSearchButton)
    }

    func test_does_not_allow_showing_search_if_loading() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            urlQueryParameters: ["category": "women/clothing"],
            mode: .listing,
            skeletonItemsSize: 2,
            navigate: { _ in },
            showSearch: {}
        )

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertFalse(sut.showSearchButton)
    }

    func test_does_not_allow_showing_search_if_showing_search_results() {
        sut = .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: "clothing",
            searchText: "something",
            sort: "sort",
            mode: .searchResults,
            navigate: { _ in },
            showSearch: {}
        )

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query, sort in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertFalse(sut.showSearchButton)
    }
}
