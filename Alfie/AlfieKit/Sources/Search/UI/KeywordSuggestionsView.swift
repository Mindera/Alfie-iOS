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
            Text.build(theme.font.heading.xSmall(L10n.Search.Screen.SuggestionsKeywords.Header.title))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.bottom, theme.sizing.spacingSpacingXs)

            ForEach(keywords, id: \.value) { keyword in
                Text.build(
                    theme.font.body.medium(keyword.value),
                    highlighting: searchTerm,
                    font: theme.font.body.mediumBold.uiFont,
                    color: theme.color.contentContentPrimary
                )
                .foregroundStyle(theme.color.contentContentPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.vertical, theme.sizing.spacingSpacingSm)
                .modifier(
                    TapHighlightableModifier(
                        action: { onSelect(keyword) },
                        accessibilityId: AccessibilityID.Search.keywordSuggestionItem
                    )
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
