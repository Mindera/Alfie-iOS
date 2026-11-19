import Foundation

public enum SuggestionsSection: Equatable, Identifiable {
    case keywords([KeywordSuggestion])
    case products([ProductSuggestion])

    public enum Kind {
        case keywords
        case products
    }

    public var id: Kind {
        switch self {
        case .keywords:
            .keywords

        case .products:
            .products
        }
    }
}
