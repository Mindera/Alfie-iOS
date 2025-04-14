import Combine
import Model

final class RecentSearchesViewModel: RecentSearchesViewModelProtocol {
    private let recentsService: RecentsServiceProtocol?
    private var subscriptions: Set<AnyCancellable> = []

    @Published var recentSearches: [RecentSearch]

    init(recentsService: RecentsServiceProtocol?) {
        self.recentsService = recentsService
        self.recentSearches = recentsService?.recentSearches ?? []
        recentsService?.recentSearchesPublisher
            .assignWeakly(to: \.recentSearches, on: self)
            .store(in: &subscriptions)
    }

    func didTapClearAll() {
        recentsService?.removeAll()
    }

    func didTapRemove(on recentSearch: RecentSearch) {
        recentsService?.remove(recentSearch)
    }

    func viewDidDisappear() {
        recentsService?.save()
    }
}
