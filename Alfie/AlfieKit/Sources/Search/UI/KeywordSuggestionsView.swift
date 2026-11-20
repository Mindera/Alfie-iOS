import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct KeywordSuggestionsView: View {
    private let keywords: [KeywordSuggestion]
    private let searchTerm: String
    private let onSelect: (KeywordSuggestion) -> Void

    init(keywords: [KeywordSuggestion], searchTerm: String, onSelect: @escaping (KeywordSuggestion) -> Void) {
        self.keywords = keywords
        self.searchTerm = searchTerm
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            SearchSectionHeader(title: L10n.Search.Screen.SuggestionsTerms.Header.title)
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.bottom, theme.sizing.spacingSpacingXs)

            ForEach(keywords, id: \.value) { keyword in
                SuggestionRow(
                    text: keyword.value,
                    searchTerm: searchTerm,
                    accessibilityId: AccessibilityID.Search.keywordSuggestion(value: keyword.value),
                    onSelect: { onSelect(keyword) }
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    KeywordSuggestionsView(
        keywords: [.fixture(value: "linen shirt"), .fixture(value: "Shirt dress")],
        searchTerm: "shirt",
        onSelect: { _ in }
    )
}
#endif
