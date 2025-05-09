import Model

public final class MockSearchViewModel: SearchViewModelProtocol {
    public var searchText: String = ""
    public var state: SearchViewState = .empty
    public var isSearchSubmissionAllowed = true
    public var suggestionTerms: [SearchSuggestionKeyword] = []
    public var suggestionBrands: [SearchSuggestionBrand] = []
    public var suggestionProducts: [Product] = []

    public init(state: SearchViewState = .empty, 
                searchText: String = "",
                suggestionTerms: [SearchSuggestionKeyword] = [],
                suggestionBrands: [SearchSuggestionBrand] = [],
                suggestionProducts: [Product] = []) {
        self.state = state
        self.searchText = searchText
        self.suggestionTerms = suggestionTerms
        self.suggestionBrands = suggestionBrands
        self.suggestionProducts = suggestionProducts
    }

    public var onViewDidAppear: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppear?()
    }

    public var onViewDidDisappear: (() -> Void)?
    public func viewDidDisappear() {
        onViewDidDisappear?()
    }

    public var onSubmitSearchText: (() -> Void)?
    public func onSubmitSearch() {
        onSubmitSearchText?()
    }

    public var onTapSearchSuggestionCalled: ((SearchSuggestionKeyword) -> Void)?
    public func onTapSearchSuggestion(_ suggestion: SearchSuggestionKeyword) {
        onTapSearchSuggestionCalled?(suggestion)
    }

    public var onCloseSearchCalled: (() -> Void)?
    public func closeSearch() {
        onCloseSearchCalled?()
    }
}
