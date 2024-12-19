import Models
import StyleGuide
import SwiftUI

struct ProductListingListStyleSelector: View {
    @Binding var selectedStyle: ProductListingListStyle

    init(selectedStyle: Binding<ProductListingListStyle>) {
        self._selectedStyle = selectedStyle
    }

    var body: some View {
        HStack(spacing: Spacing.space200) {
            Button {
                selectedStyle = .grid
            } label: {
                Icon.grid.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.filterIcon, height: Constants.filterIcon)
                    .foregroundStyle(
                        selectedStyle == .grid ? Colors.primary.mono900 : Colors.primary.mono200
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityId.listTypeGridButton)
            Button {
                selectedStyle = .list
            } label: {
                Icon.listplp.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.filterIcon, height: Constants.filterIcon)
                    .foregroundStyle(
                        selectedStyle == .list ? Colors.primary.mono900 : Colors.primary.mono200
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityId.listTypeListButton)
        }
    }

    private enum Constants {
        static let filterIcon: CGFloat = 16.0
    }

    private enum AccessibilityId {
        static let listTypeGridButton = "listTypeGridButton"
        static let listTypeListButton = "listTypeListButton"
    }
}
