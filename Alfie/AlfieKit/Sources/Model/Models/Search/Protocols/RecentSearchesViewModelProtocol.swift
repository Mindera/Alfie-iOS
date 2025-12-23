import Foundation

public protocol RecentSearchesViewModelProtocol: ObservableObject {
    var recentSearches: [RecentSearch] { get }

    func didTapRecentSearch(_ recentSearch: RecentSearch)
    func didTapClearAll()
    func didTapRemove(on recentSearch: RecentSearch)
    func viewDidDisappear()
}
