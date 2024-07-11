import Models

public final class MockRecentSearchesViewModel: RecentSearchesViewModelProtocol {
    public var recentSearches: [RecentSearch] = []

    public init() {}

    public var onDidTapClearAll: (() -> Void)?
    public func didTapClearAll() {
        onDidTapClearAll?()
    }
    
    public var onDidTapRemove: ((RecentSearch) -> Void)?
    public func didTapRemove(on recentSearch: RecentSearch) {
        onDidTapRemove?(recentSearch)
    }
    
    public var onViewDidDisappear: (() -> Void)?
    public func viewDidDisappear() {
        onViewDidDisappear?()
    }
}
