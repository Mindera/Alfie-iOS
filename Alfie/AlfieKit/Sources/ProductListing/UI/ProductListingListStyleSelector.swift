import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI

struct ProductListingListStyleSelector: View {
    @Binding var selectedStyle: ProductListingListStyle

    init(selectedStyle: Binding<ProductListingListStyle>) {
        self._selectedStyle = selectedStyle
    }

    var body: some View {
        HStack(spacing: theme.spacing.space100) {
            styleButton(
                for: .list,
                accessibilityLabel: L10n.Accessibility.listView,
                accessibilityID: AccessibilityID.ProductListing.listStyleListButton
            )
            styleButton(
                for: .grid,
                accessibilityLabel: L10n.Accessibility.gridView,
                accessibilityID: AccessibilityID.ProductListing.listStyleGridButton
            )
        }
    }

    private func styleButton(
        for style: ProductListingListStyle,
        accessibilityLabel: String,
        accessibilityID: String
    ) -> some View {
        let isSelected = selectedStyle == style
        return Button {
            selectedStyle = style
        } label: {
            ThemedIcon(
                Style.icon(for: style, isSelected: isSelected),
                size: .medium,
                tint: Theme.contentContentPrimary,
                accessibilityLabel: accessibilityLabel
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
        // Announce the active layout to VoiceOver (selection is otherwise icon-only).
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    enum Style {
        /// Selection is shown by swapping the outline icon for its filled variant (tint stays constant).
        static func icon(for style: ProductListingListStyle, isSelected: Bool) -> Icon {
            switch style {
            case .grid:
                return isSelected ? .grid2Fill : .grid
            case .list:
                return isSelected ? .grid1Fill : .listplp
            }
        }
    }
}
