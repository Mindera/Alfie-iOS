import AlicerceLogging
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

    func test_init_withNoRecentSearches_isEmptyState() {
        let sut = makeSUT()
        XCTAssertEqual(sut.state, .empty)
    }

    func test_init_withRecentSearches_isRecentSearchesState() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        XCTAssertEqual(sut.state, .recentSearches)
    }

    // MARK: - Search text changes

    func test_searchText_withNonEmptyText_setsEmptyState() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        XCTAssertEqual(sut.state, .recentSearches)

        sut.searchText = "shoes"

        XCTAssertEqual(sut.state, .empty)
    }

    func test_searchText_clearedWithRecentSearches_setsRecentSearchesState() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        sut.searchText = "shoes"
        XCTAssertEqual(sut.state, .empty)

        sut.searchText = ""

        XCTAssertEqual(sut.state, .recentSearches)
    }

    func test_searchText_clearedWithoutRecentSearches_setsEmptyState() {
        let sut = makeSUT()
        sut.searchText = "shoes"

        sut.searchText = ""

        XCTAssertEqual(sut.state, .empty)
    }

    // MARK: - Submission

    func test_isSearchSubmissionAllowed_reflectsSearchText() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isSearchSubmissionAllowed)

        sut.searchText = "shoes"

        XCTAssertTrue(sut.isSearchSubmissionAllowed)
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
