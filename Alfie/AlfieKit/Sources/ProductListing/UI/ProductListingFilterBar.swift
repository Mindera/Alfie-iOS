import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI

// MARK: - ProductListingFilterBar

struct ProductListingFilterBar: View {
    @Binding private var selectedStyle: ProductListingListStyle
    private var isLoading: Bool
    private var total: Int
    private var filterAction: () -> Void

    public init(
        style: Binding<ProductListingListStyle>,
        total: Int,
        isLoading: Bool,
        filterAction: @escaping () -> Void
    ) {
        _selectedStyle = style
        self.total = total
        self.isLoading = isLoading
        self.filterAction = filterAction
    }

    public var body: some View {
        HStack {
            ProductListingListStyleSelector(selectedStyle: $selectedStyle)
            Spacer()
            resultInfoView
                // Derived, not stored: as stored state raised only by `onChange`, the count stayed
                // invisible whenever the bar was born already loaded, since no transition occurred.
                .opacity(isLoading ? .zero : Constants.fullOpacityResults)
                .animation(.emphasizedDecelerate, value: isLoading)
            Spacer()
            refineButton
        }
        .padding(.horizontal, theme.spacing.space200)
        .padding(.vertical, theme.spacing.space050)
    }

    private var refineButton: some View {
        Button {
            filterAction()
        } label: {
            Text.build(theme.font.link.medium(L10n.Plp.Refine.Button.cta, underline: true))
                .foregroundStyle(Theme.linkLinkPrimaryDefault)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityID.ProductListing.filterButton)
    }

    private var resultInfoView: some View {
        Text.build(theme.font.body.small(L10n.Plp.NumberOfResults.message(total)))
            .foregroundStyle(Theme.contentContentTerciary)
            .accessibilityIdentifier(AccessibilityID.ProductListing.resultsLabel)
    }

    // MARK: - Constants

    private enum Constants {
        static let fullOpacityResults: CGFloat = 1
    }

}

#Preview {
    ProductListingFilterBar(
        style: .constant(.grid),
        total: 122,
        isLoading: false
    ) {}
}
