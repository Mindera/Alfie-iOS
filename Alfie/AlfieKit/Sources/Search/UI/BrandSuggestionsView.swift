import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BrandSuggestionsView: View {
    private let brands: [BrandSuggestion]
    private let searchTerm: String
    private let onSelect: (BrandSuggestion) -> Void

    init(brands: [BrandSuggestion], searchTerm: String, onSelect: @escaping (BrandSuggestion) -> Void) {
        self.brands = brands
        self.searchTerm = searchTerm
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            SearchSectionHeader(title: L10n.Search.Screen.SuggestionsBrands.Header.title)
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.bottom, theme.sizing.spacingSpacingXs)

            ForEach(brands, id: \.key) { brand in
                SuggestionRow(
                    text: brand.name,
                    searchTerm: searchTerm,
                    accessibilityId: AccessibilityID.Search.brandSuggestion(key: brand.key),
                    onSelect: { onSelect(brand) }
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    BrandSuggestionsView(
        brands: [.fixture(key: "shirt-co", name: "The Shirt Co"), .fixture(key: "alfie", name: "Alfie Shirts")],
        searchTerm: "shirt",
        onSelect: { _ in }
    )
}
#endif
