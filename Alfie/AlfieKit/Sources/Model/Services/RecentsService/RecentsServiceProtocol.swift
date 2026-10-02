import Combine

public protocol RecentsServiceProtocol {
    var recentSearches: [RecentSearch] { get }
    var recentSearchesPublisher: AnyPublisher<[RecentSearch], Never> { get }

    func add(_ recentSearch: RecentSearch)
    func remove(_ recentSearch: RecentSearch)
    func removeAll()
    func save()
}
