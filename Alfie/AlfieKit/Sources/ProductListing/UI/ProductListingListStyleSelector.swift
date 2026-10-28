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
        HStack(spacing: theme.sizing.spacingSpacingNone) {
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
                tint: theme.color.contentContentPrimary,
                accessibilityLabel: accessibilityLabel
            )
            // Figma: 24pt icon centred in a 32×32 button (two sit flush → 8pt visible gap).
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .contentShape(Rectangle())
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

private enum Constants {
    // swiftlint:disable:next no_primitive_tokens - design review #186: tap-target size, no size token
    static let buttonSize: CGFloat = Primitives.Spacing.spacing32
}
