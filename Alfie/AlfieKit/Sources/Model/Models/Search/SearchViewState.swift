import Foundation

public enum SearchSuggestionsViewErrorType: Error, Equatable {
    case generic(searchTerm: String)
    case noResults(searchTerm: String)
}

public enum SearchViewState: Equatable {
    case blank
    case recentSearches
    case suggestions(ViewState<SearchSuggestions, SearchSuggestionsViewErrorType>)
}
