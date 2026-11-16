import Foundation

public enum SearchViewState: Equatable {
    case blank
    case recentSearches
    case loading
    case suggestions(SearchSuggestions)
    case noResults(searchTerm: String)
    case error(searchTerm: String)
}
