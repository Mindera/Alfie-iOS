import Foundation

public protocol SearchViewModelProtocol: ObservableObject {
    associatedtype RecentSearchesViewModel: RecentSearchesViewModelProtocol

    var isSearchSubmissionAllowed: Bool { get }
    var searchText: String { get set }
    var state: SearchViewState { get }
    var recentSearchesViewModel: RecentSearchesViewModel { get }

    func onSubmitSearch()
    func viewDidAppear()
    func viewDidDisappear()
    func closeSearch()
}
