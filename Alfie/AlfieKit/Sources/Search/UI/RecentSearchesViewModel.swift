import Combine
import Model

public final class RecentSearchesViewModel: RecentSearchesViewModelProtocol {
    private let recentsService: RecentsServiceProtocol?
    private let navigate: (SearchRoute) -> Void
    private var subscriptions: Set<AnyCancellable> = []

    @Published public var recentSearches: [RecentSearch]

    init(
        recentsService: RecentsServiceProtocol?,
        navigate: @escaping (SearchRoute) -> Void
    ) {
        self.recentsService = recentsService
        self.navigate = navigate
        self.recentSearches = recentsService?.recentSearches ?? []
        recentsService?.recentSearchesPublisher
            .assignWeakly(to: \.recentSearches, on: self)
            .store(in: &subscriptions)
    }

    public func didTapRecentSearch(_ recentSearch: RecentSearch) {
        navigate(.searchIntent(.productListing(searchTerm: recentSearch.value, category: nil)))
    }

    public func didTapClearAll() {
        recentsService?.removeAll()
    }

    public func didTapRemove(on recentSearch: RecentSearch) {
        recentsService?.remove(recentSearch)
    }

    public func viewDidDisappear() {
        recentsService?.save()
    }
}
