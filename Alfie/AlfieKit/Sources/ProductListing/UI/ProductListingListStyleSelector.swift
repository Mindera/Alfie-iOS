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
        HStack(spacing: Primitives.Spacing.spacing16) {
            Button {
                selectedStyle = .grid
            } label: {
                ThemedIcon(
                    .grid,
                    size: .small,
                    tint: selectedStyle == .grid ? Primitives.Colours.neutrals800 : Primitives.Colours.neutrals200,
                    accessibilityLabel: L10n.Accessibility.gridView
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.ProductListing.listStyleGridButton)
            Button {
                selectedStyle = .list
            } label: {
                ThemedIcon(
                    .listplp,
                    size: .small,
                    tint: selectedStyle == .list ? Primitives.Colours.neutrals800 : Primitives.Colours.neutrals200,
                    accessibilityLabel: L10n.Accessibility.listView
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.ProductListing.listStyleListButton)
        }
    }
}
