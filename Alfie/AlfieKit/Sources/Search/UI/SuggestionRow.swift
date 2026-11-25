import SharedUI
import SwiftUI

struct SuggestionRow: View {
    private let text: String
    private let searchTerm: String
    private let accessibilityId: String
    private let onSelect: () -> Void

    init(text: String, searchTerm: String, accessibilityId: String, onSelect: @escaping () -> Void) {
        self.text = text
        self.searchTerm = searchTerm
        self.accessibilityId = accessibilityId
        self.onSelect = onSelect
    }

    var body: some View {
        Text.build(
            theme.font.body.medium(text),
            highlighting: searchTerm,
            font: theme.font.body.mediumBold.uiFont,
            color: theme.color.contentContentPrimary
        )
        .foregroundStyle(theme.color.contentContentPrimary)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
        .padding(.vertical, theme.sizing.spacingSpacingSm)
        .modifier(TapHighlightableModifier(action: onSelect, accessibilityId: accessibilityId))
    }
}

#if DEBUG
#Preview {
    SuggestionRow(text: "linen shirt", searchTerm: "shirt", accessibilityId: "", onSelect: {})
}
#endif
