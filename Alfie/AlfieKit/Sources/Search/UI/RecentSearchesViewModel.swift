import Combine
import Model

public final class RecentSearchesViewModel: RecentSearchesViewModelProtocol {
    private let recentsService: RecentsServiceProtocol?
    private let showListing: (RecentSearch) -> Void
    private var subscriptions: Set<AnyCancellable> = []

    @Published public var recentSearches: [RecentSearch]

    init(
        recentsService: RecentsServiceProtocol?,
        showListing: @escaping (RecentSearch) -> Void
    ) {
        self.recentsService = recentsService
        self.showListing = showListing
        self.recentSearches = recentsService?.recentSearches ?? []
        recentsService?.recentSearchesPublisher
            .assignWeakly(to: \.recentSearches, on: self)
            .store(in: &subscriptions)
    }

    public func didTapRecentSearch(_ recentSearch: RecentSearch) {
        showListing(recentSearch)
    }

    public func didTapRemove(on recentSearch: RecentSearch) {
        recentsService?.remove(recentSearch)
    }

    public func viewDidDisappear() {
        recentsService?.save()
    }
}
