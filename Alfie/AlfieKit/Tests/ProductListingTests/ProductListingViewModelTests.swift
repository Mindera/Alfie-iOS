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
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
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
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
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

        mockProductListing.onProductListPageCalled = { collectionHandle, _, sort, _ in
            XCTAssertEqual(collectionHandle, "clothing")
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

    func test_fetch_first_page_in_search_mode_calls_search() {
        sut = makeSUT(searchText: "something", sort: "sort", mode: .searchResults)

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.title, "")

        mockProductListing.onSearchPageCalled = { searchTerm, _, sort, _ in
            XCTAssertEqual(searchTerm, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Results",
                                          pagination: .fixture(totalCount: 5),
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.totalNumberOfProducts, 5)
    }

    func test_fetch_first_page_failure_returns_error() {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { collectionHandle, _, sort, _ in
            throw BFFRequestError(type: .product(.noProducts(category: collectionHandle, query: nil, sort: sort)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .noResults)
    }

    func test_fetch_first_page_rate_limited_returns_rate_limited_state() {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .rateLimited(retryAfter: 5))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .rateLimited)
    }

    func test_fetch_first_page_server_error_returns_server_error_state() {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
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
        // also propagated collectionHandle/sort across the second request.
        mockProductListing.onProductListPageCalled = { collectionHandle, after, sort, _ in
            if after == nil {
                return ProductListing.fixture(
                    pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                    products: Product.fixtures
                )
            }
            XCTAssertEqual(after, "cursor-1")
            XCTAssertEqual(collectionHandle, "clothing")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(products: Product.fixtures)
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.didDisplay(Product.fixtures.last!) })

        XCTAssertTrue(sut.state.isLoadingNextPage)
    }

    func test_does_not_fetch_next_page_when_no_next_page() {
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Product.fixtures)
        }

        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.sut.didDisplay(Product.fixtures.last!) })
    }

    func test_does_not_fetch_next_page_while_displaying_products() {
        guard let penultimateProduct = Product.fixtures[safe: Product.fixtures.count - 2] else {
            return
        }
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
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
            sort: "sort",
            mode: .listing,
            navigate: { _ in },
            showSearch: {}
        )

        mockProductListing.onProductListPageCalled = { collectionHandle, _, sort, _ in
            XCTAssertEqual(collectionHandle, "clothing")
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
            searchText: "something",
            sort: "sort",
            mode: .searchResults,
            navigate: { _ in },
            showSearch: {}
        )

        mockProductListing.onSearchPageCalled = { searchTerm, _, sort, _ in
            XCTAssertEqual(searchTerm, "something")
            XCTAssertEqual(sort, "sort")
            return ProductListing.fixture(title: "Results",
                                          pagination: .fixture(totalCount: 5),
                                          products: Array(Product.fixtures.prefix(5)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertFalse(sut.showSearchButton)
    }

    // MARK: - Pull-to-refresh (ALFMOB-470)

    func test_refresh_refetches_first_page_preserving_sort_and_filters() async {
        sut = makeSUT(category: "clothing", sort: "sort")
        let filters = ProductFilterInput(brandNames: ["Acme"])
        sut.filters = filters

        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(title: "Clothing", products: Array(Product.fixtures.prefix(3)))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.isSuccess)

        // Refresh must hit page 1 (after == nil) while forwarding the active sort + filters, and
        // replace the grid with the fresh response.
        var refreshedAfter: String? = "unset"
        var refreshedSort: String?
        var refreshedFilters: ProductFilterInput?
        mockProductListing.onProductListPageCalled = { _, after, sort, pageFilters in
            refreshedAfter = after
            refreshedSort = sort
            refreshedFilters = pageFilters
            return ProductListing.fixture(title: "Clothing", products: Array(Product.fixtures.suffix(2)))
        }

        await sut.refresh()

        XCTAssertNil(refreshedAfter)
        XCTAssertEqual(refreshedSort, "sort")
        XCTAssertEqual(refreshedFilters, filters)
        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.products.count, 2)
        XCTAssertNil(sut.refreshError)
    }

    func test_refresh_failure_keeps_grid_and_emits_transient_error() async {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.isSuccess)
        let seeded = sut.products.map(\.id)

        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }
        await sut.refresh()

        // Non-destructive: the grid stays on screen (still `.success`) and the failure surfaces as a
        // transient `refreshError`, never the full `.error` screen.
        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.products.map(\.id), seeded)
        XCTAssertEqual(sut.refreshError, .serverError)
    }

    func test_refresh_cancellation_keeps_grid_and_emits_no_error() async {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.isSuccess)
        let seeded = sut.products.map(\.id)

        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw CancellationError()
        }
        await sut.refresh()

        // SwiftUI cancels the `.refreshable` task routinely; nothing failed, so the grid stays and
        // no Snackbar is raised. This only holds while the service layer rethrows `CancellationError`
        // unmapped — see `ProductServiceTests.test_productList_rethrows_cancellation_unmapped`.
        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.products.map(\.id), seeded)
        XCTAssertNil(sut.refreshError)
    }

    func test_load_more_appends_next_page_and_stops_when_no_next_page() {
        sut = makeSUT(category: "clothing")
        let page1 = Array(Product.fixtures.prefix(3))
        let page2 = Array(Product.fixtures.suffix(3))
        mockProductListing.onProductListPageCalled = { _, after, _, _ in
            if after == nil {
                return ProductListing.fixture(
                    pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                    products: page1
                )
            }
            return ProductListing.fixture(pagination: .fixture(hasNextPage: false), products: page2)
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertEqual(sut.products.count, page1.count)

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.sut.didDisplay(self.sut.products.last!) }
        )
        XCTAssertEqual(sut.products.count, page1.count + page2.count)

        // hasNextPage is now false, so displaying the last item must not fetch again.
        XCTAssertNoEmit(from: sut.$state, afterTrigger: { self.sut.didDisplay(self.sut.products.last!) })
    }

    func test_refresh_after_paging_resets_to_first_page() async {
        sut = makeSUT(category: "clothing")
        let page1 = Array(Product.fixtures.prefix(3))
        let page2 = Array(Product.fixtures.suffix(3))
        mockProductListing.onProductListPageCalled = { _, after, _, _ in
            if after == nil {
                return ProductListing.fixture(
                    pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                    products: page1
                )
            }
            return ProductListing.fixture(pagination: .fixture(hasNextPage: false), products: page2)
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.sut.didDisplay(self.sut.products.last!) }
        )
        XCTAssertEqual(sut.products.count, page1.count + page2.count)

        let refreshed = Array(Product.fixtures.prefix(2))
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(pagination: .fixture(hasNextPage: false), products: refreshed)
        }
        await sut.refresh()

        XCTAssertEqual(sut.products.count, refreshed.count)
    }

    func test_filtered_pagination_forwards_filters_on_every_page_and_refresh() async {
        sut = makeSUT(category: "clothing")
        let filters = ProductFilterInput(brandNames: ["Acme"])
        sut.filters = filters

        var forwardedFilters: [ProductFilterInput?] = []
        let page1 = Array(Product.fixtures.prefix(3))
        let page2 = Array(Product.fixtures.suffix(3))
        mockProductListing.onProductListPageCalled = { _, after, _, pageFilters in
            forwardedFilters.append(pageFilters)
            if after == nil {
                return ProductListing.fixture(
                    pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                    products: page1
                )
            }
            return ProductListing.fixture(pagination: .fixture(hasNextPage: false), products: page2)
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.sut.didDisplay(self.sut.products.last!) }
        )
        await sut.refresh()

        // The dormant `ProductFilterInput` is forwarded identically on page 1, load-more, and refresh.
        XCTAssertEqual(forwardedFilters.count, 3)
        XCTAssertTrue(forwardedFilters.allSatisfy { $0 == filters })
    }

    func test_second_refresh_is_dropped_while_a_refresh_is_in_flight() async {
        sut = makeSUT(category: "clothing")

        // Seed a successful first page.
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.isSuccess)

        // Hold the first refresh's fetch open so `isFetching` stays true while a second refresh runs.
        let gate = FetchGate()
        let firstFetchInFlight = expectation(description: "first refresh fetch is in-flight")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            await gate.recordAndMaybeWait(signal: firstFetchInFlight)
            return ProductListing.fixture(products: Array(Product.fixtures.suffix(2)))
        }

        async let firstRefresh: Void = sut.refresh()
        await fulfillment(of: [firstFetchInFlight], timeout: 1)

        // Second refresh while the first is in-flight must bail on the guard (no second fetch).
        await sut.refresh()
        let fetchesWhileInFlight = await gate.entries
        XCTAssertEqual(fetchesWhileInFlight, 1)

        await gate.open()
        await firstRefresh
        let totalFetches = await gate.entries
        XCTAssertEqual(totalFetches, 1)
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_load_more_is_dropped_while_a_refresh_is_in_flight() async {
        sut = makeSUT(category: "clothing")

        // Seed page 1 with a next page so displaying the last item would normally trigger a load-more.
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(
                pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                products: Array(Product.fixtures.prefix(3))
            )
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.isSuccess)

        // Hold a refresh open, then attempt a load-more via `didDisplay` — the `isFetching` guard on
        // `loadMoreProducts` must drop it, so no second fetch runs.
        let gate = FetchGate()
        let refreshInFlight = expectation(description: "refresh fetch is in-flight")
        let loadMoreFetched = expectation(description: "load-more must not fetch during refresh")
        loadMoreFetched.isInverted = true
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            await gate.recordAndMaybeWait(signal: refreshInFlight, secondSignal: loadMoreFetched)
            return ProductListing.fixture(pagination: .fixture(hasNextPage: false), products: Array(Product.fixtures.suffix(2)))
        }

        async let refreshing: Void = sut.refresh()
        await fulfillment(of: [refreshInFlight], timeout: 1)

        sut.didDisplay(sut.products.last!)
        await fulfillment(of: [loadMoreFetched], timeout: 0.5)

        await gate.open()
        await refreshing
        let totalFetches = await gate.entries
        XCTAssertEqual(totalFetches, 1)
    }

    // MARK: - Retry (error-state recovery)

    func test_retry_refetches_first_page_from_error_state() async {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.didFail)

        mockProductListing.onProductListPageCalled = { _, after, _, _ in
            XCTAssertNil(after)
            return ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }
        await sut.retry()

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.products.count, 3)
    }

    func test_retry_stays_in_error_when_service_fails_again() async {
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.didFail)

        await sut.retry()

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .serverError)
    }

    func test_refresh_is_dropped_while_a_retry_is_in_flight() async {
        sut = makeSUT(category: "clothing")

        // Drive into the error state.
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        XCTAssertTrue(sut.state.didFail)

        // Hold the retry's page-1 fetch open, then fire a pull-to-refresh — retry must hold `isFetching`
        // so refresh bails on its guard and no second fetch races.
        let gate = FetchGate()
        let retryInFlight = expectation(description: "retry fetch is in-flight")
        let refreshFetched = expectation(description: "refresh must not fetch during retry")
        refreshFetched.isInverted = true
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            await gate.recordAndMaybeWait(signal: retryInFlight, secondSignal: refreshFetched)
            return ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }

        async let retrying: Void = sut.retry()
        await fulfillment(of: [retryInFlight], timeout: 1)

        await sut.refresh()
        await fulfillment(of: [refreshFetched], timeout: 0.5)

        await gate.open()
        await retrying
        let totalFetches = await gate.entries
        XCTAssertEqual(totalFetches, 1)
        XCTAssertTrue(sut.state.isSuccess)
    }

    // MARK: - Filter lifetime (ALFMOB-487)

    func test_applying_filters_discards_the_cursor_and_refetches_page_one() {
        sut = makeSUT(category: "clothing")
        var requestedCursors: [String?] = []
        mockProductListing.onProductListPageCalled = { _, after, _, _ in
            requestedCursors.append(after)
            return ProductListing.fixture(
                pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                products: Array(Product.fixtures.prefix(3))
            )
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        // A cursor from the unfiltered result set addresses a page that no longer exists once the
        // filter changes; carrying it over silently paginates into the previous query.
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.sut.didApplyFilters(.init(minPrice: 40), sort: nil) }
        )

        XCTAssertEqual(requestedCursors, [nil, nil])
        XCTAssertEqual(sut.filters?.minPrice, 40)
    }

    func test_changing_sort_discards_the_cursor_and_preserves_filters() {
        sut = makeSUT(category: "clothing")
        var requestedCursors: [String?] = []
        var requestedSorts: [String?] = []
        var requestedFilters: [ProductFilterInput?] = []
        mockProductListing.onProductListPageCalled = { _, after, sort, filters in
            requestedCursors.append(after)
            requestedSorts.append(sort)
            requestedFilters.append(filters)
            return ProductListing.fixture(
                pagination: .fixture(endCursor: "cursor-1", hasNextPage: true),
                products: Array(Product.fixtures.prefix(3))
            )
        }
        let filters = ProductFilterInput(minPrice: 40)
        sut.filters = filters
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.sut.didApplyFilters(filters, sort: "LOW_TO_HIGH") }
        )

        XCTAssertEqual(requestedCursors, [nil, nil])
        XCTAssertEqual(requestedSorts.last, "LOW_TO_HIGH")
        XCTAssertEqual(requestedFilters.last, filters, "A sort change must not drop the active filters")
    }

    func test_a_new_category_starts_with_no_filters() {
        // Emergent from the navigation design — a different category is a different pushed screen
        // with its own view model — so this pins it as a guarantee rather than an accident.
        sut = makeSUT(category: "clothing")
        sut.filters = ProductFilterInput(minPrice: 40)

        let other = makeSUT(category: "shoes")

        XCTAssertNil(other.filters)
        XCTAssertNil(other.priceBounds)
    }

    // MARK: - Price bounds (ALFMOB-472 semantics)

    func test_price_bounds_are_fetched_once_on_screen_entry() {
        sut = makeSUT(category: "clothing")
        var boundsFetches = 0
        mockProductListing.onCategoryPriceRangeCalled = { handle in
            boundsFetches += 1
            XCTAssertEqual(handle, "clothing")
            return PriceRange(low: self.money(1_023), high: self.money(48_000))
        }
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }

        XCTAssertEmitsValue(from: sut.$priceBounds, where: { $0 != nil }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.priceBounds?.minimum, 10, "1023 GBP minor units → £10")
        XCTAssertEqual(sut.priceBounds?.maximum, 480)
        XCTAssertEqual(boundsFetches, 1)
    }

    func test_a_failed_bounds_fetch_leaves_the_listing_alone() {
        // Bounds are auxiliary: losing them hides the Price row, it does not error the screen.
        sut = makeSUT(category: "clothing")
        mockProductListing.onCategoryPriceRangeCalled = { _ in
            throw BFFRequestError(type: .product(.generic))
        }
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertNil(sut.priceBounds)
    }

    func test_no_bounds_are_fetched_for_the_search_driven_listing() {
        // `categoryPriceRange` is keyed by collection handle, which a search has none of.
        sut = makeSUT(searchText: "shirt", mode: .searchResults)
        var boundsFetches = 0
        mockProductListing.onCategoryPriceRangeCalled = { _ in
            boundsFetches += 1
            return nil
        }
        mockProductListing.onSearchPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(boundsFetches, 0)
        XCTAssertNil(sut.priceBounds)
    }

    func test_a_category_without_bounds_is_not_requeried_on_every_appearance() {
        // `viewDidAppear` fires again on every return from a PDP. A category with no filterable
        // range yields nil legitimately, so the absence of a result must not look like "not asked".
        sut = makeSUT(category: "clothing")
        var boundsFetches = 0
        mockProductListing.onCategoryPriceRangeCalled = { _ in
            boundsFetches += 1
            return nil
        }
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })
        sut.viewDidAppear()
        sut.viewDidAppear()

        XCTAssertEqual(boundsFetches, 1)
        XCTAssertNil(sut.priceBounds)
    }

    func test_a_thrown_bounds_fetch_is_retried_on_the_next_appearance() {
        // The counterpart to the test above, and the distinction the latch has to make: a nil
        // result is a legitimate answer and must not be re-queried, but a throw is not an answer.
        // Latching on it would hide the Price row for the life of the screen with no path back.
        sut = makeSUT(category: "clothing")
        var boundsFetches = 0
        let firstFetchFailed = expectation(description: "first bounds fetch threw")
        mockProductListing.onCategoryPriceRangeCalled = { _ in
            boundsFetches += 1
            guard boundsFetches > 1 else {
                firstFetchFailed.fulfill()
                throw BFFRequestError(type: .product(.generic))
            }
            return PriceRange(low: self.money(1_023), high: self.money(48_000))
        }
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }

        sut.viewDidAppear()
        wait(for: [firstFetchFailed], timeout: 1)
        XCTAssertNil(sut.priceBounds)

        XCTAssertEmitsValue(from: sut.$priceBounds, where: { $0 != nil }, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(boundsFetches, 2)
        XCTAssertEqual(sut.priceBounds?.minimum, 10)
    }

    func test_applying_filters_clears_a_stale_refresh_error() async {
        // The Snackbar describes the previous result set; left up over a freshly filtered listing
        // it reads as the filter having failed.
        sut = makeSUT(category: "clothing")
        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.prefix(3)))
        }
        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            throw BFFRequestError(type: .serverError(status: 503))
        }
        await sut.refresh()
        XCTAssertEqual(sut.refreshError, .serverError)

        mockProductListing.onProductListPageCalled = { _, _, _, _ in
            ProductListing.fixture(products: Array(Product.fixtures.suffix(2)))
        }
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.isSuccess },
            afterTrigger: { self.sut.didApplyFilters(.init(minPrice: 40), sort: nil) }
        )

        XCTAssertNil(sut.refreshError)
    }

    func test_a_page_in_flight_when_filters_change_cannot_overwrite_the_filtered_result() async {
        // The filter bar stays tappable during a load-more, so its response can land after the
        // filter has redefined the result set. Committing it would put the pre-filter products
        // and cursor back over the newly filtered listing.
        sut = makeSUT(category: "clothing")
        let stale = Array(Product.fixtures.prefix(3))
        let fresh = Array(Product.fixtures.suffix(2))
        let gate = FetchGate()
        let firstFetchStarted = expectation(description: "stale page in flight")

        mockProductListing.onProductListPageCalled = { _, after, _, filters in
            if filters == nil {
                await gate.recordAndMaybeWait(signal: firstFetchStarted)
                return ProductListing.fixture(
                    pagination: .fixture(endCursor: "stale-cursor", hasNextPage: true),
                    products: stale
                )
            }
            XCTAssertNil(after, "The filtered fetch must start from page 1")
            return ProductListing.fixture(pagination: .fixture(hasNextPage: false), products: fresh)
        }

        sut.viewDidAppear()
        await fulfillment(of: [firstFetchStarted], timeout: 1)

        // Redefine the result set while the first fetch is suspended, then let it complete.
        sut.didApplyFilters(.init(minPrice: 40), sort: nil)
        XCTAssertEmitsValue(from: sut.$state, where: { $0.isSuccess }, afterTrigger: { Task { await gate.open() } })

        XCTAssertEqual(sut.products.map(\.id), fresh.map(\.id), "The stale page must not win")
        XCTAssertEqual(sut.filters?.minPrice, 40)
    }

    private func money(_ amount: Int) -> Money {
        Money(currencyCode: "GBP", amount: amount, amountFormatted: "")
    }
}

/// Test gate that holds the first fetch suspended until released, and counts how many fetches ran —
/// so a concurrent-fetch guard can be exercised deterministically (no sleeps, no races).
private actor FetchGate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var opened = false
    private(set) var entries = 0

    func recordAndMaybeWait(signal: XCTestExpectation, secondSignal: XCTestExpectation? = nil) async {
        entries += 1
        guard entries == 1 else {
            secondSignal?.fulfill()
            return
        }
        signal.fulfill()
        guard !opened else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        opened = true
        continuation?.resume()
        continuation = nil
    }
}
