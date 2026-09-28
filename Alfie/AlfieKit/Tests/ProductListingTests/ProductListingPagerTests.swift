import Mocks
import Model
import XCTest
@testable import ProductListing

final class ProductListingPagerTests: XCTestCase {
    private let page1 = Array(Product.fixtures.prefix(3))
    private let page2 = Array(Product.fixtures.suffix(2))

    // MARK: - Next page

    func test_next_page_appends_products_and_advances_the_cursor() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))

        let commit = sut.commit(
            .success(.fixture(pagination: .fixture(endCursor: "cursor-2", hasNextPage: false), products: page2)),
            for: ticket
        )

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.state.value?.products.map(\.id), (page1 + page2).map(\.id))
        XCTAssertNil(commit?.transientError)
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-2")
    }

    func test_beginning_a_next_page_shows_loaded_products_as_loading_next_page() throws {
        var sut = makeSUT()

        let ticket = try XCTUnwrap(sut.begin(.nextPage))

        XCTAssertEqual(ticket.cursor, "cursor-1")
        XCTAssertTrue(sut.state.isLoadingNextPage)
        XCTAssertEqual(sut.state.value?.products.map(\.id), page1.map(\.id))
    }

    func test_failed_next_page_keeps_loaded_products_and_cursor_and_emits_transient_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.state.value?.products.map(\.id), page1.map(\.id))
        XCTAssertEqual(commit?.transientError, .init(request: .nextPage, error: .serverError))
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-1")
        XCTAssertEqual(sut.pagination?.hasNextPage, true)
    }

    func test_nil_next_page_is_ignored_rather_than_raising_no_results() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))

        let commit = sut.commit(.success(nil), for: ticket)

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.state.value?.products.map(\.id), page1.map(\.id))
        XCTAssertNil(commit?.transientError)
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-1")
    }

    func test_cancelled_next_page_keeps_loaded_products_and_emits_no_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertTrue(sut.state.isSuccess)
        XCTAssertEqual(sut.state.value?.products.map(\.id), page1.map(\.id))
        XCTAssertNil(commit?.transientError)
    }

    func test_next_page_landing_after_the_result_set_changed_is_dropped() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))
        sut.resetResultSet()

        let commit = sut.commit(.success(.fixture(products: page2)), for: ticket)

        XCTAssertNil(commit)
        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.state.value?.products.count, 0)
        XCTAssertNil(sut.pagination)
    }

    func test_failed_next_page_landing_after_the_result_set_changed_is_dropped() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))
        sut.resetResultSet()

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertNil(commit)
        XCTAssertTrue(sut.state.isLoadingFirstPage)
    }

    func test_next_page_is_not_begun_while_a_page_request_is_in_flight() throws {
        var sut = makeSUT()
        _ = try XCTUnwrap(sut.begin(.nextPage))

        let second = sut.begin(.nextPage)

        XCTAssertNil(second)
    }

    func test_next_page_is_not_begun_when_there_is_no_next_page() {
        var sut = makeSUT(pagination: .fixture(endCursor: "cursor-1", hasNextPage: false))

        let ticket = sut.begin(.nextPage)

        XCTAssertNil(ticket)
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_next_page_is_not_begun_without_loaded_products() {
        var sut = ProductListingPager(
            state: .loadingFirstPage(.init(title: "", products: Product.skeletons(count: 3))),
            pagination: .fixture(endCursor: "cursor-1", hasNextPage: true)
        )

        let ticket = sut.begin(.nextPage)

        XCTAssertNil(ticket)
        XCTAssertTrue(sut.state.isLoadingFirstPage)
    }

    func test_committing_a_next_page_releases_the_in_flight_latch() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.nextPage))

        _ = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertFalse(sut.isFetching)
    }

    // MARK: - First page

    func test_first_page_replaces_skeletons_with_loaded_products() throws {
        var sut = makeSkeletonSUT()
        let ticket = try XCTUnwrap(sut.begin(.firstPage))

        let commit = sut.commit(
            .success(.fixture(title: "Clothing", pagination: .fixture(endCursor: "cursor-1", hasNextPage: true), products: page1)),
            for: ticket
        )

        XCTAssertNil(ticket.cursor)
        XCTAssertEqual(sut.state, .success(.init(title: "Clothing", products: page1)))
        XCTAssertNil(commit?.transientError)
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-1")
    }

    func test_beginning_a_first_page_keeps_the_skeletons() throws {
        var sut = makeSkeletonSUT()

        _ = try XCTUnwrap(sut.begin(.firstPage))

        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.state.value?.products.count, 3)
    }

    func test_failed_first_page_raises_a_blocking_error() throws {
        var sut = makeSkeletonSUT()
        let ticket = try XCTUnwrap(sut.begin(.firstPage))

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertEqual(sut.state, .error(.serverError))
        XCTAssertNil(commit?.transientError)
    }

    func test_first_page_with_no_results_raises_a_blocking_error() throws {
        var sut = makeSkeletonSUT()
        let ticket = try XCTUnwrap(sut.begin(.firstPage))

        let commit = sut.commit(.success(nil), for: ticket)

        XCTAssertEqual(sut.state, .error(.noResults))
        XCTAssertNil(commit?.transientError)
    }

    func test_first_page_over_a_blocking_error_shows_loading_without_skeletons() throws {
        var sut = ProductListingPager(state: .error(.serverError))

        _ = try XCTUnwrap(sut.begin(.firstPage))

        XCTAssertEqual(sut.state, .loadingFirstPage(.init(title: "", products: [])))
    }

    func test_cancelled_first_page_raises_a_blocking_error_rather_than_stranding_the_skeletons() throws {
        var sut = makeSkeletonSUT()
        let ticket = try XCTUnwrap(sut.begin(.firstPage))

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertEqual(sut.state, .error(.generic))
        XCTAssertNil(commit?.transientError)
        XCTAssertFalse(sut.isFetching)
    }

    func test_cancelled_refresh_over_a_blocking_error_keeps_it() throws {
        var sut = ProductListingPager(state: .error(.noInternet))
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertEqual(sut.state, .error(.noInternet))
        XCTAssertNil(commit?.transientError)
    }

    func test_cancelled_first_page_over_a_blocking_error_keeps_it() throws {
        var sut = ProductListingPager(state: .error(.noInternet))
        let ticket = try XCTUnwrap(sut.begin(.firstPage))

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertEqual(sut.state, .error(.noInternet))
        XCTAssertNil(commit?.transientError)
    }

    func test_cancelled_refresh_over_a_changed_result_set_raises_a_blocking_error() throws {
        var sut = makeSUT()
        sut.resetResultSet()
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertEqual(sut.state, .error(.generic))
        XCTAssertNil(commit?.transientError)
        XCTAssertFalse(sut.isFetching)
    }

    func test_first_page_is_not_begun_over_loaded_products() {
        var sut = makeSUT()

        XCTAssertNil(sut.begin(.firstPage))
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_first_page_is_not_begun_while_a_next_page_is_in_flight() throws {
        var sut = makeSUT()
        _ = try XCTUnwrap(sut.begin(.nextPage))

        XCTAssertNil(sut.begin(.firstPage))
        XCTAssertTrue(sut.state.isLoadingNextPage)
    }

    func test_first_page_is_not_begun_while_another_first_page_is_in_flight() throws {
        var sut = makeSkeletonSUT()
        _ = try XCTUnwrap(sut.begin(.firstPage))

        XCTAssertNil(sut.begin(.firstPage))
    }

    func test_first_page_is_begun_after_the_result_set_changed_mid_flight() throws {
        var sut = makeSUT()
        let stale = try XCTUnwrap(sut.begin(.nextPage))
        sut.resetResultSet()

        let ticket = try XCTUnwrap(sut.begin(.firstPage))
        XCTAssertNil(sut.commit(.success(.fixture(products: page2)), for: stale))

        XCTAssertTrue(sut.isFetching, "A stale commit must not release the current page request's latch")
        let commit = sut.commit(.success(.fixture(products: page1)), for: ticket)
        XCTAssertEqual(sut.state.value?.products.map(\.id), page1.map(\.id))
    }

    func test_first_page_landing_after_the_result_set_changed_is_dropped() throws {
        var sut = makeSkeletonSUT()
        let ticket = try XCTUnwrap(sut.begin(.firstPage))
        sut.resetResultSet()

        XCTAssertNil(sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket))
        XCTAssertTrue(sut.state.isLoadingFirstPage)
    }

    // MARK: - Refresh

    func test_refresh_replaces_loaded_products_and_resets_the_cursor() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(
            .success(.fixture(title: "Fresh", pagination: .fixture(endCursor: "cursor-new", hasNextPage: true), products: page2)),
            for: ticket
        )

        XCTAssertNil(ticket.cursor)
        XCTAssertEqual(sut.state, .success(.init(title: "Fresh", products: page2)))
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-new")
    }

    func test_beginning_a_refresh_keeps_loaded_products_on_screen() throws {
        var sut = makeSUT()

        _ = try XCTUnwrap(sut.begin(.refresh))

        XCTAssertEqual(sut.state, .success(.init(title: "Clothing", products: page1)))
    }

    func test_failed_refresh_over_loaded_products_keeps_them_and_emits_transient_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertEqual(sut.state, .success(.init(title: "Clothing", products: page1)))
        XCTAssertEqual(commit?.transientError, .init(request: .refresh, error: .serverError))
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-1")
    }

    func test_refresh_with_no_results_over_loaded_products_emits_a_transient_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(.success(nil), for: ticket)

        XCTAssertEqual(sut.state, .success(.init(title: "Clothing", products: page1)))
        XCTAssertEqual(commit?.transientError, .init(request: .refresh, error: .noResults))
    }

    func test_failed_refresh_over_a_blocking_error_stays_blocking() throws {
        var sut = ProductListingPager(state: .error(.noInternet))
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertEqual(sut.state, .error(.serverError))
        XCTAssertNil(commit?.transientError)
    }

    func test_cancelled_refresh_keeps_loaded_products_and_emits_no_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.refresh))

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertEqual(sut.state, .success(.init(title: "Clothing", products: page1)))
        XCTAssertNil(commit?.transientError)
    }

    func test_refresh_landing_after_the_result_set_changed_is_dropped() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.begin(.refresh))
        sut.resetResultSet()

        XCTAssertNil(sut.commit(.success(.fixture(products: page2)), for: ticket))
        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertNil(sut.pagination)
    }

    func test_refresh_is_not_begun_while_a_page_request_is_in_flight() throws {
        var sut = makeSUT()
        _ = try XCTUnwrap(sut.begin(.nextPage))

        XCTAssertNil(sut.begin(.refresh))
    }

    // MARK: - Helpers

    private func makeSkeletonSUT() -> ProductListingPager {
        ProductListingPager(state: .loadingFirstPage(.init(title: "", products: Product.skeletons(count: 3))))
    }

    private func makeSUT(
        pagination: ProductListing.Pagination = .fixture(endCursor: "cursor-1", hasNextPage: true)
    ) -> ProductListingPager {
        ProductListingPager(state: .success(.init(title: "Clothing", products: page1)), pagination: pagination)
    }
}
