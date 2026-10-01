import AlicerceLogging
import Mocks
import Model
import XCTest
@testable import AppFeature

final class RootTabViewModelSearchTests: XCTestCase {
    private func makeAppFeatureViewModel() -> AppFeatureViewModel {
        AppFeatureViewModel(
            serviceProvider: MockServiceProvider(),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0,
            scheduler: .immediate
        )
    }

    func test_opening_search_from_home_shows_search_and_keeps_home_highlighted() {
        let sut = makeAppFeatureViewModel().rootTabViewModel

        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        XCTAssertNotNil(sut.overlayView)
        XCTAssertEqual(sut.selectedTab, .home)
    }

    func test_opening_search_from_shop_shows_search_and_keeps_shop_highlighted() {
        let sut = makeAppFeatureViewModel().rootTabViewModel
        sut.selectedTab = .shop

        sut.categorySelectorFlowViewModel.presentSearch()

        XCTAssertNotNil(sut.overlayView)
        XCTAssertEqual(sut.selectedTab, .shop)
    }

    func test_tapping_another_tab_while_search_is_open_closes_search() {
        let sut = makeAppFeatureViewModel().rootTabViewModel
        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        sut.selectedTab = .shop

        XCTAssertNil(sut.overlayView)
        XCTAssertEqual(sut.selectedTab, .shop)
    }

    func test_tapping_current_tab_while_search_is_open_closes_search_and_returns_to_the_page_searched_from() {
        let sut = makeAppFeatureViewModel().rootTabViewModel
        sut.homeFlowViewModel.navigate(.wishlist(.wishlist))
        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        sut.popToRoot(in: .home)

        XCTAssertNil(sut.overlayView)
        XCTAssertEqual(sut.selectedTab, .home)
        XCTAssertEqual(sut.homeFlowViewModel.path.count, 1)
    }

    func test_tapping_current_tab_without_search_open_pops_to_root() {
        let sut = makeAppFeatureViewModel().rootTabViewModel
        sut.homeFlowViewModel.navigate(.wishlist(.wishlist))

        sut.popToRoot(in: .home)

        XCTAssertTrue(sut.homeFlowViewModel.path.isEmpty)
    }
}
