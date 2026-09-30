import AlicerceLogging
import Combine
import Mocks
import Model
import SwiftUI
import XCTest
@testable import Search

final class SearchFlowViewModelTests: XCTestCase {
    private func makeSUT() -> SearchFlowViewModel {
        SearchFlowViewModel(
            dependencies: SearchDependencyContainer(
                recentsService: MockRecentsService(),
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                log: Log.DummyLogger()
            ),
            intentViewBuilder: { _ in AnyView(EmptyView()) }
        )
    }

    private func makePresentedSUT() -> SearchFlowViewModel {
        let sut = makeSUT()
        sut.present()
        return sut
    }

    private let searchResults = SearchRoute.searchIntent(.productListing(searchTerm: "cream", category: nil))

    func test_init_focuses_search_bar_on_appear_and_is_not_presented() {
        let sut = makeSUT()

        XCTAssertTrue(sut.focusesSearchBarOnAppear)
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertFalse(sut.isPresented)
    }

    func test_present_presents_search() {
        let sut = makeSUT()

        sut.present()

        XCTAssertTrue(sut.isPresented)
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

    func test_closing_search_from_search_screen_dismisses_it_and_focuses_search_bar_next_time() {
        let sut = makePresentedSUT()
        sut.navigate(searchResults)
        sut.pop()

        sut.makeSearchModel().closeSearch()

        XCTAssertFalse(sut.isPresented)
        XCTAssertTrue(sut.focusesSearchBarOnAppear)
    }

    func test_close_dismisses_search_returns_to_search_screen_and_focuses_search_bar() {
        let sut = makePresentedSUT()
        sut.navigate(searchResults)

        sut.close()

        XCTAssertFalse(sut.isPresented)
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertTrue(sut.focusesSearchBarOnAppear)
    }

    func test_close_emits_no_search_overlay() {
        let sut = makePresentedSUT()
        var overlays: [AnyView?] = []
        let subscription = sut.overlayViewPublisher.sink { overlays.append($0) }

        sut.close()

        XCTAssertEqual(overlays.map { $0 != nil }, [true, false])
        subscription.cancel()
    }
}
