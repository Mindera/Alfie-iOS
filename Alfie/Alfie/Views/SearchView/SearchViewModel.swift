import Combine
import Foundation
import Model

final class SearchViewModel: SearchViewModelProtocol {
    // MARK: - Private Properties

    private var currentTask: Task<Void, Never>?
    private let dependencies: SearchDependencyContainer
    private let didUpdateSearchTermPassthrough: PassthroughSubject<String, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    private var lastSearchedText: String = ""
    @Published var state: SearchViewState = .empty
    @Published public var searchText: String {
        didSet {
            guard oldValue != searchText else {
                return
            }
            didUpdateSearchTermPassthrough.send(searchText)
        }
    }

    private var canShowRecentSearches: Bool {
        searchText.isEmpty && dependencies.recentsService?.recentSearches.isEmpty == false
    }

    var suggestionTerms: [SearchSuggestionKeyword] {
        guard case .success(let suggestion) = state else {
            return []
        }

        return Array(suggestion.keywords.prefix(Constants.maxTermsToShow))
    }

    var suggestionBrands: [SearchSuggestionBrand] {
        guard case .success(let suggestion) = state else {
            return []
        }

        return Array(suggestion.brands.prefix(Constants.maxBrandsToShow))
    }

    var suggestionProducts: [Product] {
        guard case .success(let suggestion) = state else {
            return []
        }

        return suggestion.products.prefix(Constants.maxProductsToShow).map { $0.convertToProduct() }
    }

    // MARK: - Internal Properties

    var isSearchSubmissionAllowed: Bool {
        !searchText.isEmpty
    }

    // MARK: - Initialiser

    init(dependencies: SearchDependencyContainer) {
        self.dependencies = dependencies
        self.searchText = ""
        self.state = canShowRecentSearches ? .recentSearches : .empty
        configureSubscriptions()
    }
}

// MARK: - Subscriptions

extension SearchViewModel {
    private func configureSubscriptions() {
        // swiftlint:disable:next trailing_closure
        $searchText
            .handleEvents(receiveOutput: { [weak self] _ in
                if self?.state == .noResults {
                    // To avoid the UI updating before the debounce in the subscription below, otherwise we will see the "no results for <term>" even before the search takes place
                    self?.state = .loading
                }
            })
            .debounce(for: dependencies.searchService.suggestionsDebounceInterval, scheduler: dependencies.scheduler)
            .sink { [weak self] searchText in
                self?.handleChange(on: searchText)
            }
            .store(in: &subscriptions)

        dependencies.recentsService?.recentSearchesPublisher
            .sink { [weak self] _ in
                self?.handleEmptyText()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Internal Methods

extension SearchViewModel {
    func onSubmitSearch() {
        guard isSearchSubmissionAllowed else {
            return
        }
        dependencies.recentsService?.add(.text(value: searchText))
        dependencies.analytics.trackSearch(term: searchText)
    }

    func onTapSearchSuggestion(_ suggestion: SearchSuggestionKeyword) {
        guard !suggestion.term.isEmpty else {
            return
        }
        dependencies.recentsService?.add(.text(value: suggestion.term))
    }

    func viewDidAppear() {
        lastSearchedText = ""

        guard canShowRecentSearches else {
            return
        }
        state = .recentSearches
    }

    func viewDidDisappear() {
        dependencies.recentsService?.save()
    }
}

// MARK: - Private Methods

extension SearchViewModel {
    private func handleChange(on searchText: String) {
        guard !searchText.isEmpty else {
            handleEmptyText()
            return
        }

        guard isSearchSubmissionAllowed else {
            return
        }

        guard searchText != lastSearchedText else {
            return
        }

        currentTask?.cancel()
        let handleSearchTermTask = Task {
            await handleSearchTermRequest(with: searchText)
        }
        self.currentTask = handleSearchTermTask
        Task { handleSearchTermTask }
    }

    @MainActor
    private func handleSearchTermRequest(with newSearchTerm: String) async {
        state = .loading

        let suggestion: SearchSuggestion

        do {
            suggestion = try await dependencies.searchService.getSuggestion(term: newSearchTerm)
            lastSearchedText = newSearchTerm
        } catch {
            log.error("Error fetching suggestion for search term \(newSearchTerm): \(error)")
            state = .noResults
            return
        }

        guard !suggestion.isEmpty else {
            state = .noResults
            return
        }

        state = .success(suggestion: suggestion)
    }

    private func handleEmptyText() {
        if canShowRecentSearches {
            state = .recentSearches
        } else {
            state = .empty
        }
    }
}

// MARK: - Constants

extension SearchViewModel {
    private enum Constants {
        static let searchDebounceIntervalInSeconds: Double = 0.5
        static let maxTermsToShow = 6
        static let maxBrandsToShow = 6
        static let maxProductsToShow = 8
    }
}
