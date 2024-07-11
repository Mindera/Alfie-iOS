import Combine
import Mocks
import Models
import XCTest
@testable import Alfie

final class ProductListingViewModelTests: XCTestCase {
    private var sut: ProductListingViewModel!
    private var mockProductListing: MockProductListingService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockProductListing = MockProductListingService()
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()))
    }

    override func tearDownWithError() throws {
        sut = nil
        mockProductListing = nil
        try super.tearDownWithError()
    }

    func test_loading_first_page_shows_skeleton_items() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    urlQueryParameters: ["category": "women/clothing"],
                    skeletonItemsSize: 2)

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.state.value?.title, "")
        XCTAssertEqual(sut.state.value?.products.count, 2)
    }

    func test_fetch_first_page_with_filter_params_on_landing() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    urlQueryParameters: ["category": "women/clothing"])

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.title, "")

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "women/clothing")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.title, "Women's Clothing")
        XCTAssertEqual(sut.totalNumberOfProducts, 5)
    }

    func test_fetch_first_page_with_searctText_on_landing() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    searchText: "something")

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.title, "")

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.title, "Women's Clothing")
        XCTAssertEqual(sut.totalNumberOfProducts, 5)
    }


    func test_fetch_first_page_failure_returns_error() {
        mockProductListing.onPageCalled = { categoryId, query in
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query)))
        }

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }

    func test_fetch_next_page_with_filter_params_when_displays_last_item() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    urlQueryParameters: ["category": "women/clothing"])

        mockProductListing.onPageCalled = { _, _ in
            ProductListing.fixture(pagination: .fixture(nextPage: 1),
                                   products: Product.fixtures)
        }

        mockProductListing.onHasNextCalled = { true }
        mockProductListing.onNextCalled = { categoryId, query in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "women/clothing")
            return ProductListing.fixture(products: Product.fixtures)
        }

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.isSuccess)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.didDisplay(Product.fixtures.last!)
        })

        XCTAssertTrue(sut.state.isLoadingNextPage)
    }

    func test_does_not_fetch_next_page_when_no_next_page() {
        mockProductListing.onHasNextCalled = { false }
        mockProductListing.onPageCalled = { _, _ in
            ProductListing.fixture(products: Product.fixtures)
        }

        _ = assertNoEvent(from: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.didDisplay(Product.fixtures.last!)
        })
    }

    func test_does_not_fetch_next_page_while_displaying_products() {
        guard let penultimateProduct = Product.fixtures[safe: Product.fixtures.count - 2] else {
            return
        }
        mockProductListing.onHasNextCalled = { false }
        mockProductListing.onPageCalled = { _, _ in
            ProductListing.fixture(products: Product.fixtures)
        }

        _ = assertNoEvent(from: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.didDisplay(penultimateProduct)
        })
    }

    func test_allows_showing_search_if_not_loading_and_not_showing_search_results() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    searchText: "something",
                    mode: .listing)

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertTrue(sut.showSearchButton)
    }

    func test_does_not_allow_showing_search_if_loading() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    urlQueryParameters: ["category": "women/clothing"],
                    mode: .listing,
                    skeletonItemsSize: 2)

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertFalse(sut.showSearchButton)
    }

    func test_does_not_allow_showing_search_if_showing_search_results() {
        sut = .init(productListingService: mockProductListing, plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                    category: "clothing",
                    searchText: "something",
                    mode: .searchResults)

        mockProductListing.totalOfRecords = 5
        mockProductListing.onPageCalled = { categoryId, query in
            XCTAssertEqual(categoryId, "clothing")
            XCTAssertEqual(query, "something")
            return ProductListing.fixture(title: "Women's Clothing",
                                          products: Array(Product.fixtures.prefix(5)))
        }

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertFalse(sut.showSearchButton)
    }
}
