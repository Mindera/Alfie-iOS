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
        let ticket = try XCTUnwrap(sut.beginNextPage())

        let commit = sut.commit(
            .success(.fixture(pagination: .fixture(endCursor: "cursor-2", hasNextPage: false), products: page2)),
            for: ticket
        )

        XCTAssertTrue(commit?.state.isSuccess == true)
        XCTAssertEqual(commit?.state.value?.products.map(\.id), (page1 + page2).map(\.id))
        XCTAssertNil(commit?.transientError)
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-2")
    }

    func test_beginning_a_next_page_shows_loaded_products_as_loading_next_page() throws {
        var sut = makeSUT()

        let ticket = try XCTUnwrap(sut.beginNextPage())

        XCTAssertEqual(ticket.cursor, "cursor-1")
        XCTAssertTrue(sut.state.isLoadingNextPage)
        XCTAssertEqual(sut.state.value?.products.map(\.id), page1.map(\.id))
    }

    func test_failed_next_page_keeps_loaded_products_and_cursor_and_emits_transient_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.beginNextPage())

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertTrue(commit?.state.isSuccess == true)
        XCTAssertEqual(commit?.state.value?.products.map(\.id), page1.map(\.id))
        XCTAssertEqual(commit?.transientError, .init(request: .nextPage, error: .serverError))
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-1")
        XCTAssertEqual(sut.pagination?.hasNextPage, true)
    }

    func test_nil_next_page_is_ignored_rather_than_raising_no_results() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.beginNextPage())

        let commit = sut.commit(.success(nil), for: ticket)

        XCTAssertTrue(commit?.state.isSuccess == true)
        XCTAssertEqual(commit?.state.value?.products.map(\.id), page1.map(\.id))
        XCTAssertNil(commit?.transientError)
        XCTAssertEqual(sut.pagination?.endCursor, "cursor-1")
    }

    func test_cancelled_next_page_keeps_loaded_products_and_emits_no_error() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.beginNextPage())

        let commit = sut.commit(.failure(CancellationError()), for: ticket)

        XCTAssertTrue(commit?.state.isSuccess == true)
        XCTAssertEqual(commit?.state.value?.products.map(\.id), page1.map(\.id))
        XCTAssertNil(commit?.transientError)
    }

    func test_next_page_landing_after_the_result_set_changed_is_dropped() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.beginNextPage())
        sut.resetResultSet()

        let commit = sut.commit(.success(.fixture(products: page2)), for: ticket)

        XCTAssertNil(commit)
        XCTAssertTrue(sut.state.isLoadingFirstPage)
        XCTAssertEqual(sut.state.value?.products.count, 0)
        XCTAssertNil(sut.pagination)
    }

    func test_failed_next_page_landing_after_the_result_set_changed_is_dropped() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.beginNextPage())
        sut.resetResultSet()

        let commit = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertNil(commit)
        XCTAssertTrue(sut.state.isLoadingFirstPage)
    }

    func test_next_page_is_not_begun_while_a_page_request_is_in_flight() throws {
        var sut = makeSUT()
        _ = try XCTUnwrap(sut.beginNextPage())

        let second = sut.beginNextPage()

        XCTAssertNil(second)
    }

    func test_next_page_is_not_begun_when_there_is_no_next_page() {
        var sut = makeSUT(pagination: .fixture(endCursor: "cursor-1", hasNextPage: false))

        let ticket = sut.beginNextPage()

        XCTAssertNil(ticket)
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_next_page_is_not_begun_without_loaded_products() {
        var sut = ProductListingPager(state: .loadingFirstPage(.init(title: "", products: Product.skeletons(count: 3))))
        sut.pagination = .fixture(endCursor: "cursor-1", hasNextPage: true)

        let ticket = sut.beginNextPage()

        XCTAssertNil(ticket)
        XCTAssertTrue(sut.state.isLoadingFirstPage)
    }

    func test_committing_a_next_page_releases_the_in_flight_latch() throws {
        var sut = makeSUT()
        let ticket = try XCTUnwrap(sut.beginNextPage())

        _ = sut.commit(.failure(BFFRequestError(type: .serverError(status: 503))), for: ticket)

        XCTAssertFalse(sut.isFetching)
    }

    // MARK: - Helpers

    private func makeSUT(
        pagination: ProductListing.Pagination = .fixture(endCursor: "cursor-1", hasNextPage: true)
    ) -> ProductListingPager {
        var pager = ProductListingPager(state: .success(.init(title: "Clothing", products: page1)))
        pager.pagination = pagination
        return pager
    }
}
