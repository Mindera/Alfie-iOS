import Combine
import CombineSchedulers
import Core
import Foundation
import Model
import Utils

public final class SearchViewModel: SearchViewModelProtocol {
    private enum Constants {
        static let suggestionsDebounce: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
        static let suggestionsLimit = 6
    }

    // MARK: - Private Properties

    private let dependencies: SearchDependencyContainer
    private var subscriptions: Set<AnyCancellable> = .init()
    private var suggestionsTask: Task<Void, Never>?
    private var suggestionsGeneration = 0
    private var areSuggestionsOutdated = false
    @Published public var state: SearchViewState = .blank
    public private(set) var searchTerm = ""
    @Published public var searchText: String {
        didSet {
            handleSearchTextChange()
        }
    }

    public var recentSearchesViewModel: RecentSearchesViewModel {
        RecentSearchesViewModel(
            recentsService: dependencies.recentsService,
            showResults: { [weak self] in self?.showResults(for: $0) }
        )
    }

    // MARK: - Internal Properties

    public var isSearchSubmissionAllowed: Bool {
        !searchTerm.isEmpty
    }

    private let navigate: (SearchRoute) -> Void
    private let closeSearchAction: () -> Void

    // MARK: - Initialiser

    public init(
        dependencies: SearchDependencyContainer,
        navigate: @escaping (SearchRoute) -> Void,
        closeSearchAction: @escaping () -> Void
    ) {
        self.dependencies = dependencies
        self.navigate = navigate
        self.closeSearchAction = closeSearchAction
        self.searchText = ""
        showRecentSearchesIfSearchTermIsBlank()
        configureSubscriptions()
    }

    deinit {
        suggestionsTask?.cancel()
    }
}

// MARK: - Subscriptions

extension SearchViewModel {
    private func configureSubscriptions() {
        dependencies.recentsService?.recentSearchesPublisher
            .sink { [weak self] _ in
                self?.showRecentSearchesIfSearchTermIsBlank()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Internal Methods

extension SearchViewModel {
    public func onSubmitSearch() {
        guard !searchTerm.isEmpty else {
            return
        }
        submit(searchTerm)
    }

    public func didTapKeywordSuggestion(_ keywordSuggestion: KeywordSuggestion) {
        submit(keywordSuggestion.value.trim())
    }

    public func didTapProductSuggestion(_ productSuggestion: ProductSuggestion) {
        navigate(.searchIntent(.productDetails(productID: productSuggestion.handle, product: nil)))
    }

    public func didTapMoreProducts() {
        onSubmitSearch()
    }

    public func didTapRetrySuggestions() {
        loadSuggestions(debounced: false)
    }

    public func viewDidAppear() {
        showRecentSearchesIfSearchTermIsBlank()
        if areSuggestionsOutdated {
            loadSuggestions(debounced: false)
        }
    }

    public func viewDidDisappear() {
        dependencies.recentsService?.save()
    }

    public func closeSearch() {
        closeSearchAction()
    }
}

// MARK: - Private Methods

extension SearchViewModel {
    private func handleSearchTextChange() {
        let newSearchTerm = searchText.trim()
        guard newSearchTerm != searchTerm else {
            return
        }
        searchTerm = newSearchTerm

        guard !searchTerm.isEmpty else {
            cancelPendingSuggestions()
            showRecentSearchesOrBlank()
            return
        }
        loadSuggestions(debounced: true)
    }

    private func cancelPendingSuggestions() {
        suggestionsTask?.cancel()
        suggestionsGeneration += 1
        areSuggestionsOutdated = false
    }

    private func loadSuggestions(debounced: Bool) {
        cancelPendingSuggestions()
        state = .suggestions(.loading)

        guard debounced else {
            requestSuggestions(for: searchTerm)
            return
        }
        let generation = suggestionsGeneration
        let scheduler = dependencies.scheduler
        scheduler.schedule(after: scheduler.now.advanced(by: Constants.suggestionsDebounce)) { [weak self] in
            guard let self, generation == suggestionsGeneration else {
                return
            }
            requestSuggestions(for: searchTerm)
        }
    }

    private func requestSuggestions(for requestedSearchTerm: String) {
        suggestionsTask = Task { @MainActor [weak self, dependencies] in
            let newState: SearchViewState
            do {
                let suggestions = try await dependencies.searchService.suggestions(
                    searchTerm: requestedSearchTerm,
                    limit: Constants.suggestionsLimit
                )
                let sections = Self.sections(from: suggestions)
                newState = sections.isEmpty
                    ? .suggestions(.error(.noResults(searchTerm: requestedSearchTerm)))
                    : .suggestions(.success(sections))
            } catch {
                newState = .suggestions(.error(.generic(searchTerm: requestedSearchTerm)))
            }

            guard let self, !Task.isCancelled, requestedSearchTerm == searchTerm else {
                return
            }
            state = newState
        }
    }

    private static func sections(from suggestions: SearchSuggestions) -> [SuggestionsSection] {
        let keywords = suggestions.keywords.uniqued { $0.value.lowercased() }
        var sections: [SuggestionsSection] = []
        if !keywords.isEmpty {
            sections.append(.keywords(keywords))
        }
        if !suggestions.products.isEmpty {
            sections.append(.products(suggestions.products))
        }
        return sections
    }

    private func submit(_ term: String) {
        dependencies.recentsService?.add(.text(value: term))
        dependencies.analytics.trackSearch(term: term)
        if term != searchTerm {
            cancelPendingSuggestions()
            searchTerm = term
            areSuggestionsOutdated = true
        }
        searchText = term
        showResults(for: term)
    }

    private func showResults(for searchTerm: String) {
        navigate(.searchIntent(.productListing(searchTerm: searchTerm, category: nil)))
    }

    private func showRecentSearchesIfSearchTermIsBlank() {
        guard searchTerm.isEmpty else {
            return
        }
        showRecentSearchesOrBlank()
    }

    private func showRecentSearchesOrBlank() {
        state = dependencies.recentsService?.recentSearches.isEmpty == false ? .recentSearches : .blank
    }
}
