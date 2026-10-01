import AlicerceLogging
import Mocks
import Model
import XCTest
@testable import AppFeature

final class TabOverlayWiringTests: XCTestCase {
    func test_search_on_home_keeps_the_tab_bar_visible() {
        let sut = makeSut().rootTabViewModel

        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        XCTAssertNotNil(sut.overlay)
        XCTAssertFalse(sut.isTabBarHidden)
    }

    func test_scanner_on_home_hides_the_tab_bar() {
        let sut = makeSut().rootTabViewModel

        sut.homeFlowViewModel.makeHomeViewModel().didTapScan()

        XCTAssertTrue(sut.isTabBarHidden)
    }

    func test_selecting_another_tab_while_search_is_presented_dismisses_search() {
        let sut = makeSut().rootTabViewModel
        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        sut.selectedTab = .shop

        XCTAssertNil(sut.overlay)
    }

    func test_tapping_the_current_tab_while_search_is_presented_dismisses_search() {
        let sut = makeSut().rootTabViewModel
        sut.categorySelectorFlowViewModel.presentSearch()

        sut.popToRoot(in: .home)

        XCTAssertNil(sut.overlay)
    }

    private func makeSut() -> AppFeatureViewModel {
        AppFeatureViewModel(
            serviceProvider: MockServiceProvider(),
            log: Log.DummyLogger(),
            startupCompletionDelay: 0,
            scheduler: .immediate
        )
    }
}
