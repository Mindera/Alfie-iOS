import Combine
import Core
import Foundation
import Model
import Utils

public final class SearchViewModel: SearchViewModelProtocol {
    // MARK: - Private Properties

    private let dependencies: SearchDependencyContainer
    private let didUpdateSearchTermPassthrough: PassthroughSubject<String, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    @Published public var state: SearchViewState = .blank
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

    public var recentSearchesViewModel: RecentSearchesViewModel {
        RecentSearchesViewModel(
            recentsService: dependencies.recentsService,
            showResults: { [weak self] in self?.showResults(for: $0) }
        )
    }

    // MARK: - Internal Properties

    public var isSearchSubmissionAllowed: Bool {
        !searchText.trim().isEmpty
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
        self.state = canShowRecentSearches ? .recentSearches : .blank
        configureSubscriptions()
    }
}

// MARK: - Subscriptions

extension SearchViewModel {
    private func configureSubscriptions() {
        didUpdateSearchTermPassthrough
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
    public func onSubmitSearch() {
        let term = searchText.trim()
        guard !term.isEmpty else {
            return
        }
        dependencies.recentsService?.add(.text(value: term))
        dependencies.analytics.trackSearch(term: term)
        showResults(for: term)
    }

    public func viewDidAppear() {
        guard canShowRecentSearches else {
            return
        }
        state = .recentSearches
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
    private func handleChange(on searchText: String) {
        guard searchText.isEmpty else {
            state = .blank
            return
        }
        handleEmptyText()
    }

    private func showResults(for term: String) {
        searchText = term
        navigate(.searchIntent(.productListing(searchTerm: term, category: nil)))
    }

    private func handleEmptyText() {
        state = canShowRecentSearches ? .recentSearches : .blank
    }
}
