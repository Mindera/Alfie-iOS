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
                Icon.grid.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.filterIcon, height: Constants.filterIcon)
                    .foregroundStyle(
                        selectedStyle == .grid ? Primitives.Colours.neutrals800 : Primitives.Colours.neutrals200
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.ProductListing.listStyleGridButton)
            Button {
                selectedStyle = .list
            } label: {
                Icon.listplp.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.filterIcon, height: Constants.filterIcon)
                    .foregroundStyle(
                        selectedStyle == .list ? Primitives.Colours.neutrals800 : Primitives.Colours.neutrals200
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.ProductListing.listStyleListButton)
        }
    }

    private enum Constants {
        static let filterIcon: CGFloat = 16.0
    }

}
