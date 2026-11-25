import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct SuggestionsView: View {
    private let sections: [SuggestionsSection]
    private let searchTerm: String
    private let onSelectKeyword: (KeywordSuggestion) -> Void
    private let onSelectBrand: (BrandSuggestion) -> Void
    private let onSelectProduct: (ProductSuggestion) -> Void
    private let onMoreProducts: () -> Void

    init(
        sections: [SuggestionsSection],
        searchTerm: String,
        onSelectKeyword: @escaping (KeywordSuggestion) -> Void,
        onSelectBrand: @escaping (BrandSuggestion) -> Void,
        onSelectProduct: @escaping (ProductSuggestion) -> Void,
        onMoreProducts: @escaping () -> Void
    ) {
        self.sections = sections
        self.searchTerm = searchTerm
        self.onSelectKeyword = onSelectKeyword
        self.onSelectBrand = onSelectBrand
        self.onSelectProduct = onSelectProduct
        self.onMoreProducts = onMoreProducts
    }

    var body: some View {
        ScrollView {
            VStack(spacing: theme.sizing.spacingSpacingMd) {
                ForEach(sections) { section in
                    switch section {
                    case .keywords(let keywords):
                        KeywordSuggestionsView(keywords: keywords, searchTerm: searchTerm, onSelect: onSelectKeyword)

                    case .brands(let brands):
                        BrandSuggestionsView(brands: brands, searchTerm: searchTerm, onSelect: onSelectBrand)

                    case .products(let products):
                        ProductSuggestionsView(
                            products: products,
                            onSelect: onSelectProduct,
                            onMoreProducts: onMoreProducts
                        )
                    }
                }
            }
            .padding(.vertical, theme.sizing.spacingSpacingMd)
        }
    }
}

#if DEBUG
#Preview {
    SuggestionsView(
        sections: [
            .keywords([.fixture(value: "linen shirt"), .fixture(value: "Shirt dress")]),
            .brands([.fixture(key: "shirt-co", name: "The Shirt Co")]),
            .products([.fixture(id: "1"), .fixture(id: "2")]),
        ],
        searchTerm: "shirt",
        onSelectKeyword: { _ in },
        onSelectBrand: { _ in },
        onSelectProduct: { _ in },
        onMoreProducts: {}
    )
}
#endif
