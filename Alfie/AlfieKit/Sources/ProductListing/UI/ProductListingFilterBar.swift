import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI

// MARK: - ProductListingFilterBar

struct ProductListingFilterBar: View {
    @Binding private var selectedStyle: ProductListingListStyle
    @State private var opacity: CGFloat = .zero
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
            filterView
            Spacer()
            resultInfoView
                .animation(.emphasizedDecelerate, value: opacity)
                .opacity(opacity)
            Spacer()
            ProductListingListStyleSelector(selectedStyle: $selectedStyle)
        }
        .onChange(of: isLoading) { newValue in
            if !newValue {
                withAnimation {
                    opacity = Constants.fullOpacityResults
                }
            }
        }
        .padding(.horizontal, Spacing.space200)
        .frame(minHeight: Constants.barMinHeight)
    }

    private var filterView: some View {
        Button {
            filterAction()
        } label: {
            HStack(spacing: Spacing.space100) {
                Icon.filter.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(size: Constants.filterIcon)
                    .tint(Primitives.Colours.neutrals800)
                Text
                    .build(
                        theme.font.body.medium(L10n.Plp.Refine.Button.cta)
                    )
                    .foregroundStyle(Primitives.Colours.neutrals800)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityID.ProductListing.filterButton)
    }

    private var resultInfoView: some View {
        Text.build(theme.font.body.small(L10n.Plp.NumberOfResults.message(total)))
            .foregroundStyle(Primitives.Colours.neutrals500)
            .accessibilityIdentifier(AccessibilityID.ProductListing.resultsLabel)
    }

    // MARK: - Constants

    private enum Constants {
        static let fullOpacityResults: CGFloat = 1
        static let barMinHeight: CGFloat = 60.0
        static let filterIcon: CGFloat = 16.0
    }

}

#Preview {
    ProductListingFilterBar(
        style: .constant(.grid),
        total: 122,
        isLoading: false
    ) {}
}
