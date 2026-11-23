import AlicerceLogging
import Combine
import CombineSchedulers
import Mocks
import Model
import TestUtils
import XCTest
@testable import Search

final class SearchViewModelSuggestionsTests: XCTestCase {
    private var mockRecentsService: MockRecentsService!
    private var mockSearchService: MockSearchService!
    private var mockAnalytics: MockAnalyticsTracker!
    private var scheduler: TestSchedulerOf<DispatchQueue>!
    private var requests: [SuggestionsRequest]!
    private var capturedRoutes: [SearchRoute]!

    private let shirt = ProductSuggestion.fixture(id: "shirt-1", handle: "oxford-shirt")
    private let linenShirt = KeywordSuggestion.fixture(value: "linen shirt")
    private let dress = ProductSuggestion.fixture(id: "dress-1", handle: "linen-dress")
    private let shirtCo = BrandSuggestion.fixture(key: "shirt-co-key", name: "The Shirt Co")

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRecentsService = .init()
        mockSearchService = .init()
        mockAnalytics = .init()
        scheduler = DispatchQueue.test
        requests = []
        capturedRoutes = []
        stubSuggestions { [shirt] _ in .fixture(products: [shirt]) }
    }

    override func tearDownWithError() throws {
        capturedRoutes = nil
        requests = nil
        scheduler = nil
        mockAnalytics = nil
        mockSearchService = nil
        mockRecentsService = nil
        try super.tearDownWithError()
    }

    // MARK: - Typing

    func test_typing_shows_loading_at_once() {
        let sut = makeSUT()

        sut.searchText = "s"

        XCTAssertEqual(sut.state, .suggestions(.loading))
    }

    func test_typing_makes_no_request_before_500ms() {
        let sut = makeSUT()
        sut.searchText = "shirt"

        scheduler.advance(by: .milliseconds(499))

        XCTAssertEqual(sut.state, .suggestions(.loading))
        XCTAssertEqual(requests, [])
    }

    func test_typing_requests_trimmed_search_term_with_limit_six_after_500ms() {
        let sut = makeSUT()
        sut.searchText = " shirt "

        showSuggestions(in: sut) { self.scheduler.advance(by: .milliseconds(500)) }

        XCTAssertEqual(requests, [SuggestionsRequest(searchTerm: "shirt", limit: 6)])
    }

    func test_single_character_starts_a_request() {
        let sut = makeSUT()

        showSuggestions(for: "s", in: sut)

        XCTAssertEqual(requests, [SuggestionsRequest(searchTerm: "s", limit: 6)])
    }

    func test_typing_in_quick_succession_requests_only_the_last_search_term() {
        let sut = makeSUT()
        sut.searchText = "sh"
        scheduler.advance(by: .milliseconds(300))

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(requests, [SuggestionsRequest(searchTerm: "shirt", limit: 6)])
    }

    func test_edit_leaving_trimmed_search_term_unchanged_does_nothing() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        XCTAssertNoEmit(from: sut.$state) {
            sut.searchText = "shirt "
            self.scheduler.advance(by: .milliseconds(500))
        }

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.products([shirt])]))
        XCTAssertEqual(requests, [SuggestionsRequest(searchTerm: "shirt", limit: 6)])
    }

    func test_changing_search_term_replaces_suggestions_with_loading_at_once() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.searchText = "shirts"

        XCTAssertEqual(sut.state, .suggestions(.loading))
    }

    // MARK: - Blank Search term

    func test_blank_search_term_shows_recent_searches() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.searchText = "   "

        XCTAssertEqual(sut.state, .recentSearches)
    }

    func test_blank_search_term_makes_no_request() {
        let sut = makeSUT()
        sut.searchText = "   "

        scheduler.advance(by: .milliseconds(500))

        XCTAssertEqual(sut.state, .blank)
        XCTAssertEqual(requests, [])
    }

    func test_clearing_search_term_before_500ms_makes_no_request() {
        let sut = makeSUT()
        sut.searchText = "shirt"
        scheduler.advance(by: .milliseconds(300))
        sut.searchText = ""

        scheduler.advance(by: .milliseconds(500))

        XCTAssertEqual(requests, [])
        XCTAssertEqual(sut.state, .blank)
    }

    // MARK: - Results

    func test_product_suggestions_are_shown_in_order() {
        stubSuggestions { [shirt, dress] _ in .fixture(products: [shirt, dress]) }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.products([shirt, dress])]))
    }

    func test_no_suggestions_shows_no_results_for_the_search_term() {
        stubSuggestions { _ in .fixture(products: []) }
        let sut = makeSUT()

        showSuggestions(for: " zzz ", in: sut)

        XCTAssertEqual(sut.state, .suggestions(.error(.noResults(searchTerm: "zzz"))))
    }

    func test_keyword_suggestions_without_product_suggestions_are_shown() {
        stubSuggestions { [linenShirt] _ in .fixture(keywords: [linenShirt]) }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.keywords([linenShirt])]))
    }

    func test_keyword_suggestions_are_shown_above_product_suggestions() {
        stubSuggestions { [linenShirt, shirt] _ in .fixture(keywords: [linenShirt], products: [shirt]) }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.keywords([linenShirt]), .products([shirt])]))
    }

    func test_no_keyword_suggestions_hides_the_keywords_section() {
        stubSuggestions { [shirt] _ in .fixture(keywords: [], products: [shirt]) }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.products([shirt])]))
    }

    func test_keyword_suggestions_repeated_in_the_answer_are_shown_once_ignoring_case() {
        stubSuggestions { _ in
            .fixture(
                keywords: [
                    .fixture(value: "Linen Shirt"),
                    .fixture(value: "linen shirt"),
                    .fixture(value: "linen dress"),
                    .fixture(value: "LINEN SHIRT")
                ]
            )
        }
        let sut = makeSUT()

        showSuggestions(for: "linen", in: sut)

        XCTAssertEqual(
            sut.state,
            suggestions(for: "linen", [.keywords([.fixture(value: "Linen Shirt"), .fixture(value: "linen dress")])])
        )
    }

    func test_brand_suggestions_are_shown_between_keyword_and_product_suggestions() {
        stubSuggestions { [linenShirt, shirtCo, shirt] _ in
            .fixture(keywords: [linenShirt], brands: [shirtCo], products: [shirt])
        }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(
            sut.state,
            suggestions(for: "shirt", [.keywords([linenShirt]), .brands([shirtCo]), .products([shirt])])
        )
    }

    func test_brand_suggestions_alone_are_shown() {
        stubSuggestions { [shirtCo] _ in .fixture(brands: [shirtCo]) }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.brands([shirtCo])]))
    }

    func test_no_brand_suggestions_hides_the_brands_section() {
        stubSuggestions { [linenShirt, shirt] _ in .fixture(keywords: [linenShirt], brands: [], products: [shirt]) }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.keywords([linenShirt]), .products([shirt])]))
    }

    func test_brand_suggestions_repeating_a_key_in_the_same_case_are_shown_once() {
        stubSuggestions { _ in
            .fixture(
                brands: [
                    .fixture(key: "shirt-co-key", name: "The Shirt Co"),
                    .fixture(key: "shirt-co-key", name: "Shirt Co"),
                    .fixture(key: "SHIRT-CO-KEY", name: "The Shirt Co")
                ]
            )
        }
        let sut = makeSUT()

        showSuggestions(for: "shirt", in: sut)

        XCTAssertEqual(
            sut.state,
            suggestions(
                for: "shirt",
                [
                    .brands(
                        [
                            .fixture(key: "shirt-co-key", name: "The Shirt Co"),
                            .fixture(key: "SHIRT-CO-KEY", name: "The Shirt Co")
                        ]
                    )
                ]
            )
        )
    }

    func test_failed_request_shows_error_for_the_search_term() {
        stubSuggestions { _ in throw BFFRequestError(type: .noInternet) }
        let sut = makeSUT()

        showSuggestions(for: " shirt ", in: sut)

        XCTAssertEqual(sut.state, .suggestions(.error(.generic(searchTerm: "shirt"))))
    }

    @MainActor
    func test_late_result_for_an_older_search_term_is_never_shown() async {
        let gate = makeGate()
        holdRequest(for: "shirt", at: gate) { [shirt] in .fixture(products: [shirt]) }
        let sut = makeSUT()
        sut.searchText = "shirt"
        await scheduler.advance(by: .milliseconds(500))
        await fulfillment(of: [gate.held], timeout: .default)
        await awaitSuggestions(for: "dress", in: sut)

        await gate.open()

        await fulfillment(of: [gate.released], timeout: .default)
        await assertStateStaysUnchanged(in: sut)
        XCTAssertEqual(sut.state, suggestions(for: "dress", [.products([dress])]))
    }

    @MainActor
    func test_late_error_for_an_older_search_term_is_never_shown() async {
        let gate = makeGate()
        holdRequest(for: "shirt", at: gate) { throw BFFRequestError(type: .timeout) }
        let sut = makeSUT()
        sut.searchText = "shirt"
        await scheduler.advance(by: .milliseconds(500))
        await fulfillment(of: [gate.held], timeout: .default)
        await awaitSuggestions(for: "dress", in: sut)

        await gate.open()

        await fulfillment(of: [gate.released], timeout: .default)
        await assertStateStaysUnchanged(in: sut)
        XCTAssertEqual(sut.state, suggestions(for: "dress", [.products([dress])]))
    }

    @MainActor
    func test_result_of_a_cancelled_request_is_never_shown_when_its_search_term_is_typed_again() async {
        let gate = makeGate()
        holdRequest(for: "shirt", at: gate) { [shirt] in .fixture(products: [shirt]) }
        let sut = makeSUT()
        sut.searchText = "shirt"
        await scheduler.advance(by: .milliseconds(500))
        await fulfillment(of: [gate.held], timeout: .default)
        sut.searchText = "shirts"
        sut.searchText = "shirt"

        await gate.open()

        await fulfillment(of: [gate.released], timeout: .default)
        await assertStateStaysUnchanged(in: sut)
        XCTAssertEqual(sut.state, .suggestions(.loading))
    }

    // MARK: - Try again

    func test_try_again_shows_loading_at_once() {
        stubSuggestions { _ in throw BFFRequestError(type: .noInternet) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapRetrySuggestions()

        XCTAssertEqual(sut.state, .suggestions(.loading))
    }

    func test_try_again_requests_current_search_term_without_debounce() {
        var isFailing = true
        stubSuggestions { [shirt] _ in
            guard !isFailing else { throw BFFRequestError(type: .noInternet) }
            return .fixture(products: [shirt])
        }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)
        isFailing = false

        showSuggestions(in: sut) { sut.didTapRetrySuggestions() }

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.products([shirt])]))
        XCTAssertEqual(
            requests,
            [SuggestionsRequest(searchTerm: "shirt", limit: 6), SuggestionsRequest(searchTerm: "shirt", limit: 6)]
        )
    }

    // MARK: - Product suggestion

    func test_tapping_product_suggestion_opens_its_pdp_by_handle() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapProductSuggestion(shirt)

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productDetails(productID: "oxford-shirt", product: nil))])
    }

    func test_tapping_product_suggestion_saves_no_recent_search_and_tracks_nothing() {
        var added: [RecentSearch] = []
        mockRecentsService.onAdd = { added.append($0) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapProductSuggestion(shirt)

        XCTAssertEqual(added, [])
        XCTAssertTrue(mockAnalytics.trackedEvents.isEmpty)
    }

    func test_view_appearing_again_keeps_search_term_and_suggestions() {
        mockRecentsService.recentSearches = [.text(value: "polo")]
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)
        sut.didTapProductSuggestion(shirt)

        sut.viewDidAppear()

        XCTAssertEqual(sut.searchText, "shirt")
        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.products([shirt])]))
    }

    // MARK: - Keyword suggestion

    func test_tapping_keyword_suggestion_shows_search_results_for_it() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapKeywordSuggestion(linenShirt)

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "linen shirt", category: nil))])
    }

    func test_tapping_keyword_suggestion_puts_it_in_the_search_field() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapKeywordSuggestion(linenShirt)

        XCTAssertEqual(sut.searchText, "linen shirt")
    }

    func test_tapping_keyword_suggestion_saves_recent_search_and_tracks_search() {
        var added: [RecentSearch] = []
        mockRecentsService.onAdd = { added.append($0) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapKeywordSuggestion(linenShirt)

        XCTAssertEqual(added, [.text(value: "linen shirt")])
        XCTAssertEqual(mockAnalytics.trackedValues(of: .searchTerm, for: .search), ["linen shirt"])
    }

    func test_tapping_keyword_suggestion_with_surrounding_whitespace_uses_it_trimmed() {
        var added: [RecentSearch] = []
        mockRecentsService.onAdd = { added.append($0) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapKeywordSuggestion(.fixture(value: " linen shirt "))

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "linen shirt", category: nil))])
        XCTAssertEqual(added, [.text(value: "linen shirt")])
        XCTAssertEqual(mockAnalytics.trackedValues(of: .searchTerm, for: .search), ["linen shirt"])
    }

    func test_tapping_keyword_suggestion_requests_no_suggestions() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        XCTAssertNoEmit(from: sut.$state) {
            sut.didTapKeywordSuggestion(self.linenShirt)
            self.scheduler.advance(by: .milliseconds(500))
        }

        XCTAssertEqual(requests, [SuggestionsRequest(searchTerm: "shirt", limit: 6)])
    }

    func test_view_appearing_again_after_keyword_tap_shows_suggestions_for_the_keyword() {
        stubSuggestions { [shirt, dress] searchTerm in
            .fixture(products: [searchTerm == "linen shirt" ? dress : shirt])
        }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)
        sut.didTapKeywordSuggestion(linenShirt)

        showSuggestions(in: sut) { sut.viewDidAppear() }

        XCTAssertEqual(sut.state, suggestions(for: "linen shirt", [.products([dress])]))
        XCTAssertEqual(
            requests,
            [SuggestionsRequest(searchTerm: "shirt", limit: 6), SuggestionsRequest(searchTerm: "linen shirt", limit: 6)]
        )
    }

    func test_view_appearing_again_after_keyword_tap_requests_suggestions_only_once() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)
        sut.didTapKeywordSuggestion(linenShirt)
        showSuggestions(in: sut) { sut.viewDidAppear() }

        XCTAssertNoEmit(from: sut.$state) {
            sut.viewDidAppear()
        }
    }

    // MARK: - Brand suggestion

    func test_tapping_brand_suggestion_opens_the_brand_listing_with_its_key_and_name() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapBrandSuggestion(shirtCo)

        XCTAssertEqual(capturedRoutes, [.searchIntent(.brandListing(.init(key: "shirt-co-key", name: "The Shirt Co")))])
    }

    func test_tapping_brand_suggestion_puts_the_brand_name_in_the_search_field() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapBrandSuggestion(shirtCo)

        XCTAssertEqual(sut.searchText, "The Shirt Co")
    }

    func test_tapping_brand_suggestion_saves_brand_recent_search_and_tracks_nothing() {
        var added: [RecentSearch] = []
        mockRecentsService.onAdd = { added.append($0) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapBrandSuggestion(shirtCo)

        XCTAssertEqual(added, [.brand(.init(key: "shirt-co-key", name: "The Shirt Co"))])
        XCTAssertTrue(mockAnalytics.trackedEvents.isEmpty)
    }

    func test_tapping_brand_suggestion_requests_no_suggestions() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        XCTAssertNoEmit(from: sut.$state) {
            sut.didTapBrandSuggestion(self.shirtCo)
            self.scheduler.advance(by: .milliseconds(500))
        }

        XCTAssertEqual(requests, [SuggestionsRequest(searchTerm: "shirt", limit: 6)])
    }

    func test_view_appearing_again_after_brand_tap_shows_suggestions_for_the_brand_name() {
        stubSuggestions { [shirt, dress] searchTerm in
            .fixture(products: [searchTerm == "The Shirt Co" ? dress : shirt])
        }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)
        sut.didTapBrandSuggestion(shirtCo)

        showSuggestions(in: sut) { sut.viewDidAppear() }

        XCTAssertEqual(sut.state, suggestions(for: "The Shirt Co", [.products([dress])]))
    }

    func test_tapping_brand_suggestion_with_surrounding_whitespace_uses_its_name_trimmed() {
        var added: [RecentSearch] = []
        mockRecentsService.onAdd = { added.append($0) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapBrandSuggestion(.fixture(key: "shirt-co-key", name: " The Shirt Co "))

        XCTAssertEqual(capturedRoutes, [.searchIntent(.brandListing(.init(key: "shirt-co-key", name: "The Shirt Co")))])
        XCTAssertEqual(added, [.brand(.init(key: "shirt-co-key", name: "The Shirt Co"))])
        XCTAssertEqual(sut.searchText, "The Shirt Co")
    }

    // MARK: - More Products

    func test_more_products_shows_search_results_for_current_search_term() {
        let sut = makeSUT()
        showSuggestions(for: " shirt ", in: sut)

        sut.didTapMoreProducts()

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "shirt", category: nil))])
    }

    func test_more_products_saves_recent_search_and_tracks_search() {
        var added: [RecentSearch] = []
        mockRecentsService.onAdd = { added.append($0) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.didTapMoreProducts()

        XCTAssertEqual(added, [.text(value: "shirt")])
        XCTAssertEqual(mockAnalytics.trackedValues(of: .searchTerm, for: .search), ["shirt"])
    }

    // MARK: - Submit

    func test_submit_while_loading_shows_search_results() {
        let sut = makeSUT()
        sut.searchText = "shirt"

        sut.onSubmitSearch()

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "shirt", category: nil))])
    }

    func test_submit_while_suggestions_are_shown_shows_search_results() {
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.onSubmitSearch()

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "shirt", category: nil))])
    }

    func test_submit_after_failed_request_shows_search_results() {
        stubSuggestions { _ in throw BFFRequestError(type: .noInternet) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.onSubmitSearch()

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "shirt", category: nil))])
    }

    func test_submit_with_no_results_shows_search_results() {
        stubSuggestions { _ in .fixture(products: []) }
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        sut.onSubmitSearch()

        XCTAssertEqual(capturedRoutes, [.searchIntent(.productListing(searchTerm: "shirt", category: nil))])
    }

    // MARK: - Recent searches

    func test_tapping_recent_search_makes_no_request() {
        mockRecentsService.recentSearches = [.text(value: "linen")]
        let sut = makeSUT()
        sut.recentSearchesViewModel.didTapRecentSearch(.text(value: "linen"))

        scheduler.advance(by: .milliseconds(500))

        XCTAssertEqual(sut.state, .recentSearches)
        XCTAssertEqual(requests, [])
    }

    func test_tapping_brand_recent_search_reopens_the_brand_listing_by_its_key() {
        let recentSearch = RecentSearch.brand(.init(key: "shirt-co-key", name: "The Shirt Co"))
        mockRecentsService.recentSearches = [recentSearch]
        let sut = makeSUT()

        sut.recentSearchesViewModel.didTapRecentSearch(recentSearch)

        XCTAssertEqual(capturedRoutes, [.searchIntent(.brandListing(.init(key: "shirt-co-key", name: "The Shirt Co")))])
        XCTAssertEqual(sut.searchText, "The Shirt Co")
    }

    func test_tapping_brand_recent_search_tracks_nothing_and_makes_no_request() {
        let recentSearch = RecentSearch.brand(.init(key: "shirt-co-key", name: "The Shirt Co"))
        mockRecentsService.recentSearches = [recentSearch]
        let sut = makeSUT()

        sut.recentSearchesViewModel.didTapRecentSearch(recentSearch)
        scheduler.advance(by: .milliseconds(500))

        XCTAssertTrue(mockAnalytics.trackedEvents.isEmpty)
        XCTAssertEqual(requests, [])
    }

    func test_recent_searches_changing_keeps_suggestions() {
        let recentSearches = PassthroughSubject<[RecentSearch], Never>()
        mockRecentsService.recentSearchesPublisher = recentSearches.eraseToAnyPublisher()
        let sut = makeSUT()
        showSuggestions(for: "shirt", in: sut)

        mockRecentsService.recentSearches = [.text(value: "polo")]
        recentSearches.send([.text(value: "polo")])

        XCTAssertEqual(sut.state, suggestions(for: "shirt", [.products([shirt])]))
    }

    // MARK: - Helpers

    private func makeSUT() -> SearchViewModel {
        SearchViewModel(
            dependencies: SearchDependencyContainer(
                recentsService: mockRecentsService,
                searchService: mockSearchService,
                analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
                scheduler: scheduler.eraseToAnyScheduler(),
                log: Log.DummyLogger()
            ),
            navigate: { [weak self] in self?.capturedRoutes.append($0) },
            closeSearchAction: {}
        )
    }

    private func suggestions(for searchTerm: String, _ sections: [SuggestionsSection]) -> SearchViewState {
        .suggestions(.success(.init(searchTerm: searchTerm, sections: sections)))
    }

    private func stubSuggestions(_ answer: @escaping (String) throws -> SearchSuggestions) {
        mockSearchService.onSuggestionsCalled = { @MainActor [weak self] searchTerm, limit in
            self?.requests?.append(SuggestionsRequest(searchTerm: searchTerm, limit: limit))
            return try answer(searchTerm)
        }
    }

    private func makeGate() -> SuggestionsGate {
        SuggestionsGate(
            held: expectation(description: "request held"),
            released: expectation(description: "held request answered")
        )
    }

    private func holdRequest(
        for heldSearchTerm: String,
        at gate: SuggestionsGate,
        answer: @escaping () throws -> SearchSuggestions
    ) {
        mockSearchService.onSuggestionsCalled = { [dress] searchTerm, _ in
            guard searchTerm == heldSearchTerm else {
                return .fixture(products: [dress])
            }
            await gate.hold()
            return try answer()
        }
    }

    private func showSuggestions(
        for searchText: String,
        in sut: SearchViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        showSuggestions(in: sut, file: file, line: line) {
            sut.searchText = searchText
            self.scheduler.advance(by: .milliseconds(500))
        }
    }

    private func showSuggestions(
        in sut: SearchViewModel,
        file: StaticString = #filePath,
        line: UInt = #line,
        after trigger: @escaping () -> Void
    ) {
        let shown = XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0 != .suggestions(.loading) },
            afterTrigger: trigger
        )
        XCTAssertNotNil(shown, "Suggestions never left loading", file: file, line: line)
    }

    @MainActor
    private func awaitSuggestions(
        for searchText: String,
        in sut: SearchViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let shown = XCTestExpectation(description: "suggestions shown")
        let cancellable = sut.$state
            .dropFirst()
            .first { $0 != .suggestions(.loading) }
            .sink { _ in shown.fulfill() }
        sut.searchText = searchText
        await scheduler.advance(by: .milliseconds(500))
        let result = await XCTWaiter().fulfillment(of: [shown], timeout: .default)
        cancellable.cancel()
        XCTAssertEqual(result, .completed, "Suggestions never left loading", file: file, line: line)
    }

    @MainActor
    private func assertStateStaysUnchanged(
        in sut: SearchViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let changed = XCTestExpectation(description: "state changed")
        let cancellable = sut.$state.dropFirst().sink { _ in changed.fulfill() }
        let result = await XCTWaiter().fulfillment(of: [changed], timeout: .inverted)
        cancellable.cancel()
        XCTAssertEqual(result, .timedOut, "State changed", file: file, line: line)
    }
}

private actor SuggestionsGate {
    nonisolated let held: XCTestExpectation
    nonisolated let released: XCTestExpectation
    private var continuation: CheckedContinuation<Void, Never>?

    init(held: XCTestExpectation, released: XCTestExpectation) {
        self.held = held
        self.released = released
    }

    func hold() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            held.fulfill()
        }
        released.fulfill()
    }

    func open() {
        continuation?.resume()
        continuation = nil
    }
}

private struct SuggestionsRequest: Equatable {
    let searchTerm: String
    let limit: Int
}
