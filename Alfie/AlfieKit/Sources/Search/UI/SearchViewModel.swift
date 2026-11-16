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
    private var searchTerm = ""
    private var suggestionsTask: Task<Void, Never>?
    private var suggestionsGeneration = 0
    @Published public var state: SearchViewState = .blank
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
        dependencies.recentsService?.add(.text(value: searchTerm))
        dependencies.analytics.trackSearch(term: searchTerm)
        showResults(for: searchTerm)
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
        let term = searchText.trim()
        guard term != searchTerm else {
            return
        }
        searchTerm = term
        loadSuggestions(debounced: true)
    }

    private func loadSuggestions(debounced: Bool) {
        suggestionsTask?.cancel()
        suggestionsGeneration += 1

        guard !searchTerm.isEmpty else {
            showRecentSearchesIfSearchTermIsBlank()
            return
        }
        state = .loading

        let term = searchTerm
        guard debounced else {
            requestSuggestions(for: term)
            return
        }
        let generation = suggestionsGeneration
        let scheduler = dependencies.scheduler
        scheduler.schedule(after: scheduler.now.advanced(by: Constants.suggestionsDebounce)) { [weak self] in
            guard let self, generation == suggestionsGeneration else {
                return
            }
            requestSuggestions(for: term)
        }
    }

    private func requestSuggestions(for term: String) {
        suggestionsTask = Task { @MainActor [weak self, dependencies] in
            let newState: SearchViewState
            do {
                let suggestions = try await dependencies.searchService.suggestions(
                    searchTerm: term,
                    limit: Constants.suggestionsLimit
                )
                newState = Self.state(showing: suggestions, for: term)
            } catch {
                newState = .error(searchTerm: term)
            }

            guard let self, !Task.isCancelled, term == searchTerm else {
                return
            }
            state = newState
        }
    }

    private static func state(showing suggestions: SearchSuggestions, for term: String) -> SearchViewState {
        var seenProductIDs = Set<String>()
        let products = suggestions.products.filter { seenProductIDs.insert($0.id).inserted }
        guard !products.isEmpty else {
            return .noResults(searchTerm: term)
        }
        return .suggestions(
            SearchSuggestions(keywords: suggestions.keywords, brands: suggestions.brands, products: products)
        )
    }

    private func showResults(for term: String) {
        searchText = term
        navigate(.searchIntent(.productListing(searchTerm: term, category: nil)))
    }

    private func showRecentSearchesIfSearchTermIsBlank() {
        guard searchTerm.isEmpty else {
            return
        }
        state = dependencies.recentsService?.recentSearches.isEmpty == false ? .recentSearches : .blank
    }
}
