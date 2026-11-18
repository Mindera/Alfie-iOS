import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct SuggestionsView: View {
    private let suggestions: SearchSuggestions
    private let searchTerm: String
    private let onSelectKeyword: (KeywordSuggestion) -> Void
    private let onSelectProduct: (ProductSuggestion) -> Void
    private let onMoreProducts: () -> Void

    init(
        suggestions: SearchSuggestions,
        searchTerm: String,
        onSelectKeyword: @escaping (KeywordSuggestion) -> Void,
        onSelectProduct: @escaping (ProductSuggestion) -> Void,
        onMoreProducts: @escaping () -> Void
    ) {
        self.suggestions = suggestions
        self.searchTerm = searchTerm
        self.onSelectKeyword = onSelectKeyword
        self.onSelectProduct = onSelectProduct
        self.onMoreProducts = onMoreProducts
    }

    var body: some View {
        ScrollView {
            VStack(spacing: theme.sizing.spacingSpacingMd) {
                if !suggestions.keywords.isEmpty {
                    KeywordSuggestionsView(
                        keywords: suggestions.keywords,
                        searchTerm: searchTerm,
                        onSelect: onSelectKeyword
                    )
                }
                if !suggestions.products.isEmpty {
                    ProductSuggestionsView(
                        products: suggestions.products,
                        onSelect: onSelectProduct,
                        onMoreProducts: onMoreProducts
                    )
                    .padding(.horizontal, theme.sizing.spacingSpacingMd)
                }
            }
            .padding(.vertical, theme.sizing.spacingSpacingMd)
        }
    }
}

#if DEBUG
#Preview {
    SuggestionsView(
        suggestions: .fixture(
            keywords: [.fixture(value: "linen shirt"), .fixture(value: "Shirt dress")],
            products: [.fixture(id: "1"), .fixture(id: "2")]
        ),
        searchTerm: "shirt",
        onSelectKeyword: { _ in },
        onSelectProduct: { _ in },
        onMoreProducts: {}
    )
}
#endif
