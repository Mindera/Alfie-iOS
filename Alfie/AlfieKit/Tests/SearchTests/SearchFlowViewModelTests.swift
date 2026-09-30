import AlicerceLogging
import Combine
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

    // MARK: - Search screen on top

    private func recordSearchScreenOnTop(of sut: SearchFlowViewModel) -> (values: () -> [Bool], subscription: AnyCancellable) {
        var values: [Bool] = []
        let subscription = sut.isSearchScreenOnTopPublisher.sink { values.append($0) }
        return ({ values }, subscription)
    }

    func test_pushing_search_results_takes_search_screen_off_top() {
        let sut = makeSUT()
        let recorder = recordSearchScreenOnTop(of: sut)

        sut.navigate(searchResults)

        XCTAssertEqual(recorder.values(), [true, false])
    }

    func test_popping_back_to_search_screen_puts_it_on_top_again() {
        let sut = makeSUT()
        sut.navigate(searchResults)
        let recorder = recordSearchScreenOnTop(of: sut)

        sut.pop()

        XCTAssertEqual(recorder.values(), [false, true])
    }

    func test_pushing_a_product_page_over_search_results_keeps_search_screen_off_top() {
        let sut = makeSUT()
        sut.navigate(searchResults)
        let recorder = recordSearchScreenOnTop(of: sut)

        sut.navigate(.searchIntent(.productDetails(productID: "1", product: nil)))

        XCTAssertEqual(recorder.values(), [false])
    }

    func test_reset_returns_to_search_screen_and_focuses_search_bar() {
        let sut = makeSUT()
        sut.navigate(searchResults)

        sut.reset()

        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertTrue(sut.focusesSearchBarOnAppear)
    }
}
