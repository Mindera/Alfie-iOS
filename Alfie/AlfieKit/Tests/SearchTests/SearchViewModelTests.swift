import AlicerceLogging
import Combine
import XCTest
import Mocks
import Model
@testable import Search

final class SearchViewModelTests: XCTestCase {
    private var mockRecentsService: MockRecentsService!
    private var dependencies: SearchDependencyContainer!
    private let mockAnalytics = MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
    private var log = Log.DummyLogger()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRecentsService = .init()
        dependencies = SearchDependencyContainer(
            recentsService: mockRecentsService,
            analytics: mockAnalytics,
            log: log
        )
    }

    override func tearDownWithError() throws {
        dependencies = nil
        mockRecentsService = nil
        try super.tearDownWithError()
    }

    private func makeSUT(
        navigate: @escaping (SearchRoute) -> Void = { _ in },
        closeSearchAction: @escaping () -> Void = {}
    ) -> SearchViewModel {
        SearchViewModel(dependencies: dependencies, navigate: navigate, closeSearchAction: closeSearchAction)
    }

    // MARK: - Initial state

    func test_init_without_recent_searches_is_blank() {
        let sut = makeSUT()

        XCTAssertEqual(sut.state, .blank)
    }

    func test_init_withRecentSearches_isRecentSearchesState() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        XCTAssertEqual(sut.state, .recentSearches)
    }

    // MARK: - Search text changes

    func test_typing_with_recent_searches_is_blank() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()

        sut.searchText = "shoes"

        XCTAssertEqual(sut.state, .blank)
    }

    func test_searchText_clearedWithRecentSearches_setsRecentSearchesState() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        sut.searchText = "shoes"

        sut.searchText = ""

        XCTAssertEqual(sut.state, .recentSearches)
    }

    func test_clearing_search_text_without_recent_searches_is_blank() {
        let sut = makeSUT()
        sut.searchText = "shoes"

        sut.searchText = ""

        XCTAssertEqual(sut.state, .blank)
    }

    // MARK: - Recent searches changes

    func test_removing_last_recent_search_is_blank() {
        let recentSearches = CurrentValueSubject<[RecentSearch], Never>([.text(value: "polo")])
        mockRecentsService.recentSearches = [.text(value: "polo")]
        mockRecentsService.recentSearchesPublisher = recentSearches.eraseToAnyPublisher()
        let sut = makeSUT()

        mockRecentsService.recentSearches = []
        recentSearches.send([])

        XCTAssertEqual(sut.state, .blank)
    }

    func test_recent_searches_changing_while_typing_stays_blank() {
        let recentSearches = CurrentValueSubject<[RecentSearch], Never>([])
        mockRecentsService.recentSearchesPublisher = recentSearches.eraseToAnyPublisher()
        let sut = makeSUT()
        sut.searchText = "shoes"

        mockRecentsService.recentSearches = [.text(value: "polo")]
        recentSearches.send([.text(value: "polo")])

        XCTAssertEqual(sut.state, .blank)
    }

    // MARK: - Submission

    func test_isSearchSubmissionAllowed_reflectsSearchText() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isSearchSubmissionAllowed)

        sut.searchText = "shoes"

        XCTAssertTrue(sut.isSearchSubmissionAllowed)
    }

    func test_isSearchSubmissionAllowed_isFalseForWhitespaceOnlyText() {
        let sut = makeSUT()

        sut.searchText = "   "

        XCTAssertFalse(sut.isSearchSubmissionAllowed)
    }

    func test_onSubmitSearch_withTerm_navigatesToProductListingWithSearchTerm() {
        var capturedRoute: SearchRoute?
        let sut = makeSUT(navigate: { capturedRoute = $0 })
        sut.searchText = "shoes"

        sut.onSubmitSearch()

        guard case .searchIntent(.productListing(let searchTerm, let category)) = capturedRoute else {
            return XCTFail("Expected productListing intent, got \(String(describing: capturedRoute))")
        }
        XCTAssertEqual(searchTerm, "shoes")
        XCTAssertNil(category)
    }

    func test_onSubmitSearch_withTerm_addsRecentSearch() {
        var added: RecentSearch?
        mockRecentsService.onAdd = { added = $0 }
        let sut = makeSUT()
        sut.searchText = "shoes"

        sut.onSubmitSearch()

        XCTAssertEqual(added, .text(value: "shoes"))
    }

    func test_onSubmitSearch_withEmptyTerm_doesNotNavigate() {
        var capturedRoute: SearchRoute?
        let sut = makeSUT(navigate: { capturedRoute = $0 })

        sut.onSubmitSearch()

        XCTAssertNil(capturedRoute)
    }

    func test_onSubmitSearch_withWhitespaceOnlyTerm_doesNotNavigate() {
        var capturedRoute: SearchRoute?
        var added: RecentSearch?
        mockRecentsService.onAdd = { added = $0 }
        let sut = makeSUT(navigate: { capturedRoute = $0 })
        sut.searchText = "   "

        sut.onSubmitSearch()

        XCTAssertNil(capturedRoute)
        XCTAssertNil(added)
    }

    func test_onSubmitSearch_trimsTermBeforeNavigating() {
        var capturedRoute: SearchRoute?
        let sut = makeSUT(navigate: { capturedRoute = $0 })
        sut.searchText = "  shoes  "

        sut.onSubmitSearch()

        guard case .searchIntent(.productListing(let searchTerm, _)) = capturedRoute else {
            return XCTFail("Expected productListing intent, got \(String(describing: capturedRoute))")
        }
        XCTAssertEqual(searchTerm, "shoes")
    }

    // MARK: - Lifecycle

    func test_viewDidAppear_withRecentSearches_setsRecentSearchesState() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        sut.state = .blank

        sut.viewDidAppear()

        XCTAssertEqual(sut.state, .recentSearches)
    }

    func test_view_did_appear_without_recent_searches_stays_blank() {
        let sut = makeSUT()

        sut.viewDidAppear()

        XCTAssertEqual(sut.state, .blank)
    }

    func test_viewDidDisappear_savesRecentSearches() {
        var saved = false
        mockRecentsService.onSave = { saved = true }
        let sut = makeSUT()

        sut.viewDidDisappear()

        XCTAssertTrue(saved)
    }

    func test_closeSearch_invokesCloseAction() {
        var closed = false
        let sut = makeSUT(closeSearchAction: { closed = true })

        sut.closeSearch()

        XCTAssertTrue(closed)
    }
}
