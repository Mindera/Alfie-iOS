import AlicerceLogging
import Combine
import Mocks
import Model
import XCTest
@testable import AppFeature

final class RootTabViewModelTabBarTests: XCTestCase {
    private var isSearchScreenOnTop: CurrentValueSubject<Bool, Never>!
    private var closeSearchCount = 0

    override func setUpWithError() throws {
        try super.setUpWithError()
        isSearchScreenOnTop = .init(false)
        closeSearchCount = 0
    }

    override func tearDownWithError() throws {
        isSearchScreenOnTop = nil
        try super.tearDownWithError()
    }

    private func makeSUT(initialTab: Model.Tab = .home) -> some RootTabViewModelProtocol {
        let serviceProvider = MockServiceProvider()
        let flows = makeAppFeatureViewModel(serviceProvider: serviceProvider).rootTabViewModel

        return RootTabViewModel(
            tabs: flows.tabs,
            initialTab: initialTab,
            serviceProvider: serviceProvider,
            bagFlowViewModel: flows.bagFlowViewModel,
            categorySelectorFlowViewModel: flows.categorySelectorFlowViewModel,
            homeFlowViewModel: flows.homeFlowViewModel,
            wishlistFlowViewModel: flows.wishlistFlowViewModel,
            myAccountFlowViewModel: flows.myAccountFlowViewModel,
            isSearchScreenOnTop: isSearchScreenOnTop.eraseToAnyPublisher(),
            closeSearch: { [weak self] in self?.closeSearchCount += 1 },
            scheduler: .immediate
        )
    }

    func test_init_without_search_shows_tab_bar() {
        let sut = makeSUT()

        XCTAssertFalse(sut.isTabBarHidden)
    }

    func test_search_screen_on_top_hides_tab_bar() {
        let sut = makeSUT()

        isSearchScreenOnTop.send(true)

        XCTAssertTrue(sut.isTabBarHidden)
    }

    func test_search_screen_covered_by_search_results_or_product_page_shows_tab_bar() {
        let sut = makeSUT()
        isSearchScreenOnTop.send(true)

        isSearchScreenOnTop.send(false)

        XCTAssertFalse(sut.isTabBarHidden)
    }

    func test_popping_back_to_search_screen_hides_tab_bar() {
        let sut = makeSUT()
        isSearchScreenOnTop.send(true)
        isSearchScreenOnTop.send(false)

        isSearchScreenOnTop.send(true)

        XCTAssertTrue(sut.isTabBarHidden)
    }

    func test_tapping_another_tab_closes_search() {
        let sut = makeSUT(initialTab: .home)

        sut.selectedTab = .shop

        XCTAssertEqual(closeSearchCount, 1)
    }

    func test_tapping_current_tab_closes_search() {
        let sut = makeSUT(initialTab: .home)

        sut.popToRoot(in: .home)

        XCTAssertEqual(closeSearchCount, 1)
        XCTAssertEqual(sut.selectedTab, .home)
    }

    // MARK: - App graph wiring

    private func makeAppFeatureViewModel(
        serviceProvider: MockServiceProvider = MockServiceProvider()
    ) -> AppFeatureViewModel {
        AppFeatureViewModel(
            serviceProvider: serviceProvider,
            log: Log.DummyLogger(),
            startupCompletionDelay: 0,
            scheduler: .immediate
        )
    }

    func test_opening_search_from_home_hides_tab_bar_and_keeps_home_highlighted() {
        let sut = makeAppFeatureViewModel().rootTabViewModel

        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        XCTAssertTrue(sut.isTabBarHidden)
        XCTAssertEqual(sut.selectedTab, .home)
    }

    func test_opening_search_from_shop_hides_tab_bar_and_keeps_shop_highlighted() {
        let sut = makeAppFeatureViewModel().rootTabViewModel
        sut.selectedTab = .shop

        sut.categorySelectorFlowViewModel.presentSearch()

        XCTAssertTrue(sut.isTabBarHidden)
        XCTAssertEqual(sut.selectedTab, .shop)
    }

    func test_tapping_a_tab_while_search_is_open_closes_search_and_shows_tab_bar() {
        let sut = makeAppFeatureViewModel().rootTabViewModel
        sut.homeFlowViewModel.makeHomeViewModel().didTapSearch()

        sut.selectedTab = .shop

        XCTAssertFalse(sut.isTabBarHidden)
        XCTAssertNil(sut.overlayView)
    }
}
