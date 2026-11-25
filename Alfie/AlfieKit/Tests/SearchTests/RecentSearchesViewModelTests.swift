import Combine
import Mocks
import Model
import XCTest
import TestUtils
@testable import Search

final class RecentSearchesViewModelTests: XCTestCase {
    private var mockRecentsService: MockRecentsService!
    private var sut: RecentSearchesViewModel!

    override func setUp() {
        super.setUp()
        mockRecentsService = MockRecentsService()
        mockRecentsService.recentSearchesPublisher = Just([
            .recentSearch1,
            .recentSearch2,
            .recentSearch3,
            .recentSearch4
        ]).eraseToAnyPublisher()
        sut = makeSUT()
    }

    override func tearDown() {
        sut = nil
        mockRecentsService = nil
        super.tearDown()
    }

    func test_OnInit_RecentSearches_ReturnsCorrectValue() {
        XCTAssertEqual(sut.recentSearches, [.recentSearch1, .recentSearch2, .recentSearch3, .recentSearch4])
    }

    func test_DidTapRemove_InRecentsService_CallsRemoveRecentSearch() {
        let expectation = expectation(description: "DidTapRemove_InRecentsService_CallsRemoveRecentSearch")
        mockRecentsService.onRemove = { recentSearch in
            XCTAssertEqual(recentSearch, .recentSearch2)
            expectation.fulfill()
        }
        sut.didTapRemove(on: .recentSearch2)
        waitForExpectations(timeout: .default)
    }

    private func makeSUT(showListing: @escaping (RecentSearch) -> Void = { _ in }) -> RecentSearchesViewModel {
        RecentSearchesViewModel(recentsService: mockRecentsService, showListing: showListing)
    }

    func test_did_tap_search_term_recent_search_shows_results_for_it() {
        var captured: [RecentSearch] = []
        sut = makeSUT { captured.append($0) }

        sut.didTapRecentSearch(.text(value: "linen"))

        XCTAssertEqual(captured, [.text(value: "linen")])
    }

    func test_did_tap_brand_recent_search_shows_results_for_it() {
        var captured: [RecentSearch] = []
        sut = makeSUT { captured.append($0) }

        sut.didTapRecentSearch(.brand(suggestion: .fixture(key: "acme-key", name: "Acme")))

        XCTAssertEqual(captured, [.brand(suggestion: .fixture(key: "acme-key", name: "Acme"))])
    }

    func test_OnViewDidDisappear_InRecentsService_CallsSave() {
        let expectation = expectation(description: "OnViewDidDisappear_InRecentsService_CallsSave")
        mockRecentsService.onSave = {
            expectation.fulfill()
        }
        sut.viewDidDisappear()
        waitForExpectations(timeout: .default)
    }
}
