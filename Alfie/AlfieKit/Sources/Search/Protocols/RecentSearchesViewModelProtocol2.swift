import Foundation
import Model

public protocol RecentSearchesViewModelProtocol2: ObservableObject {
    var recentSearches: [RecentSearch] { get }

    func didTapRecentSearch(_ recentSearch: RecentSearch)
    func didTapClearAll()
    func didTapRemove(on recentSearch: RecentSearch)
    func viewDidDisappear()
}
