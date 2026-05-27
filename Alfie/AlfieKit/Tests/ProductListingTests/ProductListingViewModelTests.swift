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

    // MARK: - totalCount surfacing (AC 5)

    func test_totalNumberOfProducts_surfaces_latest_response_totalCount() {
        sut = makeSUT(category: "clothing")
        mockProductListing.onPageCalled = { _, _, _, _, _ in
            ProductListing.fixture(pagination: .fixture(totalCount: 42), products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertEqual(sut.totalNumberOfProducts, 42)
    }

    func test_totalNumberOfProducts_defaults_to_zero_before_first_response() {
        XCTAssertEqual(sut.totalNumberOfProducts, 0)
    }

    func test_totalNumberOfProducts_defaults_to_zero_when_totalCount_omitted() {
        sut = makeSUT(category: "clothing")
        mockProductListing.onPageCalled = { _, _, _, _, _ in
            ProductListing.fixture(pagination: .fixture(totalCount: nil), products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertEqual(sut.totalNumberOfProducts, 0)
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

    private func makeSUT(
        category: String? = nil,
        searchText: String? = nil,
        sort: String? = nil,
        urlQueryParameters: [String: String]? = nil,
        mode: ProductListingViewMode = .listing,
        skeletonItemsSize: Int = ProductListingViewModel.Constants.defaultSkeletonItemsSize,
        wishlistService: WishlistServiceProtocol? = nil
    ) -> ProductListingViewModel {
        .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: mockProductListing,
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: wishlistService ?? mockWishlistService,
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: log
            ),
            category: category,
            searchText: searchText,
            sort: sort,
            urlQueryParameters: urlQueryParameters,
            mode: mode,
            skeletonItemsSize: skeletonItemsSize,
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

        mockProductListing.onPageCalled = { _, categoryId, query, sort, _ in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "women/clothing")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          pagination: .fixture(totalCount: 5),
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

        mockProductListing.onPageCalled = { _, categoryId, query, sort, _ in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          pagination: .fixture(totalCount: 5),
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.title, "Women's Clothing")
        XCTAssertEqual(sut.totalNumberOfProducts, 5)
    }

    func test_fetch_first_page_failure_returns_error() {
        mockProductListing.onPageCalled = { _, categoryId, query, sort, _ in
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query, sort: sort)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .noResults)
    }

    func test_fetch_first_page_rate_limited_returns_rate_limited_state() {
        mockProductListing.onPageCalled = { _, _, _, _, _ in
            throw BFFRequestError(type: .rateLimited(retryAfter: 5))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.state.failure, .rateLimited)
    }

    func test_fetch_first_page_server_error_returns_server_error_state() {
        mockProductListing.onPageCalled = { _, _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.state.failure, .serverError)
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

        // First call (after == nil) returns a page with hasNextPage=true + cursor.
        // Second call (after == "cursor-1") proves the VM forwarded the stored cursor and
        // also propagated category/query/sort across the second request.
        mockProductListing.onPageCalled = { after, categoryId, query, sort, _ in
            if after == nil {
                return ProductListing.fixture(
                    pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                    products: Product.fixtures
                )
            }
            XCTAssertEqual(after, "cursor-1")
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
        mockProductListing.onPageCalled = { _, _, _, _, _ in
            ProductListing.fixture(products: Product.fixtures)
        }

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.sut.didDisplay(Product.fixtures.last!) })
    }

    func test_does_not_fetch_next_page_while_displaying_products() {
        guard let penultimateProduct = Product.fixtures[safe: Product.fixtures.count - 2] else {
            return
        }
        mockProductListing.onPageCalled = { _, _, _, _, _ in
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

        mockProductListing.onPageCalled = { _, categoryId, query, sort, _ in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          pagination: .fixture(totalCount: 5),
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

        mockProductListing.onPageCalled = { _, categoryId, query, sort, _ in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Women's Clothing",
                                          pagination: .fixture(totalCount: 5),
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertFalse(sut.showSearchButton)
    }
}
