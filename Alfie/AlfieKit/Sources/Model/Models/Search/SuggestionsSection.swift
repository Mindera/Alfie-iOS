import Foundation

public enum SuggestionsSection: Equatable, Identifiable {
    case keywords([KeywordSuggestion])
    case brands([BrandSuggestion])
    case products([ProductSuggestion])

    public enum Kind {
        case keywords
        case brands
        case products
    }

    public var id: Kind {
        switch self {
        case .keywords:
            .keywords

        case .brands:
            .brands

        case .products:
            .products
        }
    }
}
