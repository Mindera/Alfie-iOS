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
        HStack(spacing: theme.spacing.space200) {
            styleButton(
                for: .grid,
                icon: .grid,
                accessibilityLabel: L10n.Accessibility.gridView,
                accessibilityID: AccessibilityID.ProductListing.listStyleGridButton
            )
            styleButton(
                for: .list,
                icon: .listplp,
                accessibilityLabel: L10n.Accessibility.listView,
                accessibilityID: AccessibilityID.ProductListing.listStyleListButton
            )
        }
    }

    private func styleButton(
        for style: ProductListingListStyle,
        icon: Icon,
        accessibilityLabel: String,
        accessibilityID: String
    ) -> some View {
        Button {
            selectedStyle = style
        } label: {
            ThemedIcon(
                icon,
                size: .small,
                tint: Style.iconTint(isSelected: selectedStyle == style),
                accessibilityLabel: accessibilityLabel
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }

    enum Style {
        static func iconTint(isSelected: Bool) -> Color {
            isSelected ? Theme.contentContentPrimary : Theme.borderSoft
        }
    }
}
