import Foundation

public struct SuggestionsContent: Equatable {
    public let searchTerm: String
    public let sections: [SuggestionsSection]

    public init(searchTerm: String, sections: [SuggestionsSection]) {
        self.searchTerm = searchTerm
        self.sections = sections
    }
}
