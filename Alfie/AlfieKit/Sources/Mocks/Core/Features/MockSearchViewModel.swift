import Model

public final class MockSearchViewModel: SearchViewModelProtocol {
    public typealias RecentSearchesViewModel = MockRecentSearchesViewModel

    public var searchText: String = ""
    public var state: SearchViewState = .empty
    public var isSearchSubmissionAllowed = true
    public var recentSearchesViewModel: MockRecentSearchesViewModel = MockRecentSearchesViewModel()

    public init(state: SearchViewState = .empty,
                searchText: String = "") {
        self.state = state
        self.searchText = searchText
    }

    public var onSubmitSearchText: (() -> Void)?
    public func onSubmitSearch() {
        onSubmitSearchText?()
    }

    public var onViewDidAppear: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppear?()
    }

    public var onViewDidDisappear: (() -> Void)?
    public func viewDidDisappear() {
        onViewDidDisappear?()
    }

    public var onCloseSearchCalled: (() -> Void)?
    public func closeSearch() {
        onCloseSearchCalled?()
    }
}
