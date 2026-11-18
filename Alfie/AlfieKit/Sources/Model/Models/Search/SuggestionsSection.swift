import Foundation

public enum SuggestionsSection: Equatable, Identifiable {
    case keywords([KeywordSuggestion])
    case products([ProductSuggestion])

    public enum ID {
        case keywords
        case products
    }

    public var id: ID {
        switch self {
        case .keywords:
            .keywords

        case .products:
            .products
        }
    }
}
