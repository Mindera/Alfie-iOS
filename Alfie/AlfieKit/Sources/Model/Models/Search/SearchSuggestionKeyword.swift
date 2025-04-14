import Foundation

public struct SearchSuggestionKeyword: Identifiable, Equatable, Hashable {
    /// Local Unique ID for the instance (not mapped to any remote value)
    public let id: String
    /// Value of the suggested search term.
    public let term: String
    /// Number of results that match the suggested search term.
    public let resultCount: Int

    public init(id: String = UUID().uuidString, term: String, resultCount: Int) {
        self.id = id
        self.term = term
        self.resultCount = resultCount
    }
}
