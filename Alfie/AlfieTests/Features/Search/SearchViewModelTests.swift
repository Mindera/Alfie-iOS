import XCTest
import Mocks
import Models
@testable import Alfie

final class SearchViewModelTests: XCTestCase {
    private var mockDependencies: SearchDependencyContainer!
    private var mockRecentsService: MockRecentsService!
    private var mockSearchService: MockSearchService!
    private var sut: SearchViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRecentsService = .init()
        mockSearchService = .init()
        mockDependencies = SearchDependencyContainer(
            executionQueue: DispatchQueue.global(),
            recentsService: mockRecentsService,
            searchService: mockSearchService
        )
        sut = .init(dependencies: mockDependencies)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        mockRecentsService = nil
        mockSearchService = nil
        try super.tearDownWithError()
    }

    // MARK: - Search text

    func test_searchText_withEmptyText_setsToEmptyState() {
        sut.searchText = ""
        waitUntil(publisher: sut.$state.eraseToAnyPublisher(), 
                  emitsValue: .empty,
                  timeout: defaultTimeout)
    }

    func test_searchText_withEmptyText_setsToRecentSearches() {
        mockRecentsService.recentSearches = [.text(value: "something")]
        sut = .init(dependencies: mockDependencies)
        sut.searchText = ""
        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .recentSearches,
                  timeout: defaultTimeout)
    }

    func test_searchText_withText_setsToEmptyState() {
        sut.searchText = "aa"
        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .empty,
                  timeout: defaultTimeout)
    }

    func test_searchText_SetsToLoadingState() {
        sut.searchText = "aaaa"
        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .loading,
                  timeout: defaultTimeout)
    }

    func test_isSubmitionAllowed_withEmptySearchTerm_returnsFalse() {
        sut.searchText = ""
        XCTAssertFalse(sut.isSearchSubmissionAllowed)
    }

    func test_isSubmitionAllowed_withSearchTerm_returnsTrue() {
        sut.searchText = "something"
        XCTAssertTrue(sut.isSearchSubmissionAllowed)
    }

    func test_clearing_search_text_when_recents_are_available_sets_recents_state() {
        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .empty,
                  asyncOperation: { self.sut.searchText = "something" },
                  timeout: defaultTimeout)
        
        mockRecentsService.recentSearches = [.text(value: "something")]

        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .recentSearches,
                  asyncOperation: { self.sut.searchText = "" },
                  timeout: defaultTimeout)
    }

    func test_clearing_search_text_when_recents_are_not_available_sets_empty_state() {
        mockRecentsService.recentSearches = [.text(value: "something")]

        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .recentSearches,
                  asyncOperation: { self.sut.searchText = "" },
                  timeout: defaultTimeout)

        mockRecentsService.recentSearches = []

        waitUntil(publisher: sut.$state.eraseToAnyPublisher(),
                  emitsValue: .empty,
                  asyncOperation: { self.sut.searchText = "" },
                  timeout: defaultTimeout)
    }

    // MARK: - Recent Seaches

    func test_onSubmitTerm_addsToRecentsService() {
        let expectation = expectation(description: "onSubmitTerm_AddsToRecentsService")
        let expectedRecentTerm = "gucci"
        mockRecentsService.onAdd = { recentSearch in
            XCTAssertEqual(recentSearch, .text(value: expectedRecentTerm))
            expectation.fulfill()
        }
        sut.searchText = expectedRecentTerm
        sut.onSubmitSearch()
        waitForExpectations(timeout: defaultTimeout)
    }

    func test_onSubmitTerm_emptySearch_addsToRecentsService() {
        let expectation = expectation(description: "onSubmitTerm_AddsToRecentsService")
        expectation.isInverted = true
        mockRecentsService.onAdd = { recentSearch in
            expectation.fulfill()
        }
        sut.searchText = ""
        sut.onSubmitSearch()
        waitForExpectations(timeout: defaultTimeout)
    }

    func test_onViewDidDisappear_savesInRecentsService() {
        let expectation = expectation(description: "onViewDidDisappear_SavesInRecentsService")
        mockRecentsService.onSave = {
            expectation.fulfill()
        }
        sut.viewDidDisappear()
        waitForExpectations(timeout: defaultTimeout)
    }

    func test_show_recent_searches_when_view_appears_and_recents_are_available() {
        mockRecentsService.recentSearches = [.text(value: "something")]

       captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state, .recentSearches)
    }

    func test_does_not_show_recent_searches_when_view_appears_and_recents_are_not_available() {
        mockRecentsService.recentSearches = []

        let result = assertNoEvent(from: sut.$state.drop(while: { $0 == .empty }).eraseToAnyPublisher(), afterTrigger: { sut.viewDidAppear() }, timeout: defaultTimeout)
        XCTAssertTrue(result)
    }

    func test_does_not_show_recent_searches_when_view_appears_and_recents_service_is_not_available() {
        mockDependencies = SearchDependencyContainer(recentsService: nil, searchService: mockSearchService)
        sut = .init(dependencies: mockDependencies)

        let result = assertNoEvent(from: sut.$state.drop(while: { $0 == .empty }).eraseToAnyPublisher(), afterTrigger: { sut.viewDidAppear() }, timeout: defaultTimeout)
        XCTAssertTrue(result)
    }

    // MARK: - Special cases

    func test_updating_search_text_sets_loading_state_if_current_state_is_no_results() {
        mockSearchService.onGetSuggestionCalled = { _ in
            return .fixture()
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { $0 != .noResults }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "Something"
        })

        XCTAssertEqual(sut.state, .noResults)

       captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "Somethin"
        })

        XCTAssertEqual(sut.state, .loading)
    }

    // MARK: - Search Suggestions

    func test_gets_search_suggestions_from_service_when_search_text_is_updated() {
        let searchText = "something"
        let expectation = expectation(description: "Wait for service call")
        mockSearchService.onGetSuggestionCalled = { term in
            XCTAssertEqual(term, searchText)
            expectation.fulfill()
            return .fixture()
        }

        sut.searchText = searchText
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_sets_no_results_state_when_service_fails_to_get_suggestions() {
        mockSearchService.onGetSuggestionCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { $0 != .noResults }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.state, .noResults)
    }

    func test_sets_no_results_state_when_service_returns_no_suggestions() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture()
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { $0 != .noResults }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.state, .noResults)
    }

    func test_sets_success_state_when_service_returns_suggestions() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(brands: [.fixture()])
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.state.isSuccess, true)
    }

    func test_suggestion_terms_are_not_available_if_did_not_fetch() {
        XCTAssertEqual(sut.suggestionTerms.isEmpty, true)
    }

    func test_suggestion_terms_are_available_after_fetching() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(keywords: [
                .fixture(term: "Term 1"),
                .fixture(term: "Term 2"),
            ])
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.suggestionTerms.count, 2)
        XCTAssertEqual(sut.suggestionTerms[0].term, "Term 1")
        XCTAssertEqual(sut.suggestionTerms[1].term, "Term 2")
    }

    func test_suggestion_terms_returned_are_truncated_when_many_are_fetched() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(keywords: Array(repeating: SearchSuggestionKeyword.fixture(), count: 100))
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.suggestionTerms.count, 6)
    }

    func test_suggestion_brands_are_not_available_if_did_not_fetch() {
        XCTAssertEqual(sut.suggestionBrands.isEmpty, true)
    }

    func test_suggestion_brands_are_available_after_fetching() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(brands: [
                .fixture(name: "Brand 1", slug: "slug-1"),
                .fixture(name: "Brand 2", slug: "slug-2"),
            ])
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.suggestionBrands.count, 2)
        XCTAssertEqual(sut.suggestionBrands[0].name, "Brand 1")
        XCTAssertEqual(sut.suggestionBrands[0].slug, "slug-1")
        XCTAssertEqual(sut.suggestionBrands[1].name, "Brand 2")
        XCTAssertEqual(sut.suggestionBrands[1].slug, "slug-2")
    }

    func test_suggestion_brands_returned_are_truncated_when_many_are_fetched() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(brands: Array(repeating: SearchSuggestionBrand.fixture(), count: 100))
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.suggestionBrands.count, 6)
    }

    func test_suggestion_products_are_not_available_if_did_not_fetch() {
        XCTAssertEqual(sut.suggestionProducts.isEmpty, true)
    }

    func test_suggestion_products_are_available_after_fetching() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(products: [
                .fixture(name: "Product 1"),
                .fixture(name: "Product 2"),
            ])
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.suggestionProducts.count, 2)
        XCTAssertEqual(sut.suggestionProducts[0].name, "Product 1")
        XCTAssertEqual(sut.suggestionProducts[1].name, "Product 2")
    }

    func test_suggestion_products_returned_are_truncated_when_many_are_fetched() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(products: Array(repeating: SearchSuggestionProduct.fixture(), count: 100))
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.suggestionProducts.count, 8)
    }

    func test_selecting_a_suggested_term_adds_to_recents_service() {
        let expectation = expectation(description: "Wait for service call")
        let term = "gucci"
        let suggestionTerm = SearchSuggestionKeyword(term: term, resultCount: 0)
        mockRecentsService.onAdd = { recentSearch in
            XCTAssertEqual(recentSearch, .text(value: term))
            expectation.fulfill()
        }
        sut.onTapSearchSuggestion(suggestionTerm)
        waitForExpectations(timeout: defaultTimeout)
    }

    func test_selecting_an_empty_suggested_term_does_not_add_to_recents_service() {
        let expectation = expectation(description: "Wait for service call")
        expectation.isInverted = true
        let suggestionTerm = SearchSuggestionKeyword(term: "", resultCount: 0)
        mockRecentsService.onAdd = { _ in
            expectation.fulfill()
        }
        sut.onTapSearchSuggestion(suggestionTerm)
        waitForExpectations(timeout: defaultTimeout)
    }

    func test_suggestions_are_not_fetched_if_search_term_is_the_same_as_before() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(brands: [
                .fixture(name: "Brand 1", slug: "slug-1"),
            ])
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.state.isSuccess, true)

        let result = assertNoEvent(from: sut.$state.eraseToAnyPublisher(), afterTrigger: { sut.searchText = "something" }, timeout: defaultTimeout)
        XCTAssertTrue(result)
    }

    func test_suggestions_are_fetched_if_search_term_is_the_same_as_before_but_view_reappeared_in_between() {
        mockSearchService.onGetSuggestionCalled = { _ in
            .fixture(brands: [
                .fixture(name: "Brand 1", slug: "slug-1"),
            ])
        }

       captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isSuccess }).eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.state.isSuccess, true)

        sut.viewDidAppear()

       captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.searchText = "something"
        })

        XCTAssertEqual(sut.state, .loading)
    }
}
