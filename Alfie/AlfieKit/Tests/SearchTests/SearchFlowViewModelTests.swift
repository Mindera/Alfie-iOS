import AlicerceLogging
import Mocks
import Model
import SwiftUI
import XCTest
@testable import Search

final class SearchFlowViewModelTests: XCTestCase {
    private func makeSUT(closeSearchAction: @escaping () -> Void = {}) -> SearchFlowViewModel {
        SearchFlowViewModel(
            dependencies: SearchDependencyContainer(
                recentsService: MockRecentsService(),
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                log: Log.DummyLogger()
            ),
            intentViewBuilder: { _ in AnyView(EmptyView()) },
            closeSearchAction: closeSearchAction
        )
    }

    private let searchResults = SearchRoute.searchIntent(.productListing(searchTerm: "cream", category: nil))

    func test_init_focuses_search_bar_on_appear() {
        let sut = makeSUT()

        XCTAssertTrue(sut.focusesSearchBarOnAppear)
        XCTAssertTrue(sut.path.isEmpty)
    }

    func test_opening_search_results_stops_focusing_search_bar_on_appear() {
        let sut = makeSUT()

        sut.navigate(searchResults)

        XCTAssertFalse(sut.focusesSearchBarOnAppear)
        XCTAssertEqual(sut.path.count, 1)
    }

    func test_going_back_from_search_results_keeps_search_bar_unfocused() {
        let sut = makeSUT()
        sut.navigate(searchResults)

        sut.pop()

        XCTAssertFalse(sut.focusesSearchBarOnAppear)
        XCTAssertTrue(sut.path.isEmpty)
    }

    func test_returning_to_search_to_edit_search_term_focuses_search_bar() {
        let sut = makeSUT()
        sut.navigate(searchResults)

        sut.navigate(.search)

        XCTAssertTrue(sut.focusesSearchBarOnAppear)
        XCTAssertTrue(sut.path.isEmpty)
    }

    func test_closing_search_focuses_search_bar_next_time_it_opens() {
        var closeCount = 0
        let sut = makeSUT(closeSearchAction: { closeCount += 1 })
        sut.navigate(searchResults)
        sut.pop()

        sut.makeSearchModel().closeSearch()

        XCTAssertTrue(sut.focusesSearchBarOnAppear)
        XCTAssertEqual(closeCount, 1)
    }
}
