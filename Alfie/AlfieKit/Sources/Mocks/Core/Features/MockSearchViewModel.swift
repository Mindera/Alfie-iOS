import Model

public final class MockSearchViewModel: SearchViewModelProtocol {
    public typealias RecentSearchesViewModel = MockRecentSearchesViewModel

    public var searchText: String = ""
    public var state: SearchViewState = .empty
    public var isSearchSubmissionAllowed = true
    public var suggestionTerms: [SearchSuggestionKeyword] = []
    public var suggestionBrands: [SearchSuggestionBrand] = []
    public var suggestionProducts: [Product] = []
    public var recentSearchesViewModel: MockRecentSearchesViewModel = MockRecentSearchesViewModel()

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

    public var onSubmitSearchText: (() -> Void)?
    public func onSubmitSearch() {
        onSubmitSearchText?()
    }

    public var onTapSearchBrandCalled: ((SearchSuggestionBrand) -> Void)?
    public func onTapSearchBrand(_ brand: SearchSuggestionBrand) {
        onTapSearchBrandCalled?(brand)
    }

    public var onTapSearchSuggestionCalled: ((SearchSuggestionKeyword) -> Void)?
    public func onTapSearchSuggestion(_ suggestion: SearchSuggestionKeyword) {
        onTapSearchSuggestionCalled?(suggestion)
    }

    public var onTapProductCalled: ((Product) -> Void)?
    public func onTapProduct(_ product: Product) {
        onTapProductCalled?(product)
    }

    public var onTapOpenBrandsCalled: (() -> Void)?
    public func onTapOpenBrands() {
        onTapOpenBrandsCalled?()
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
