import Foundation

public enum SearchViewState: Equatable {
    case empty
    case loading
    case noResults
    case recentSearches
    case success(suggestion: SearchSuggestion)
}

public extension SearchViewState {
    var isSuccess: Bool {
        guard case .success = self else {
            return false
        }
        return true
    }
}
