import Models
import StyleGuide
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
                    .tint(Colors.primary.mono900)
                Text
                    .build(
                        theme.font.paragraph.normal(L10n.Plp.Refine.Button.cta)
                    )
                    .foregroundStyle(Colors.primary.mono900)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityId.filterButton)
    }

    private var resultInfoView: some View {
        Text.build(theme.font.tiny.normal(L10n.Plp.NumberOfResults.message(total)))
            .foregroundStyle(Colors.primary.mono500)
            .accessibilityIdentifier(AccessibilityId.resultsLabel)
    }

    // MARK: - Constants

    private enum Constants {
        static let fullOpacityResults: CGFloat = 1
        static let barMinHeight: CGFloat = 60.0
        static let filterIcon: CGFloat = 16.0
    }

    // MARK: - Accessibility Id's

    private enum AccessibilityId {
        static let filterButton = "filter-btn"
        static let resultsLabel = "results-lbl"
    }
}

#Preview {
    ProductListingFilterBar(
        style: .constant(.grid),
        total: 122,
        isLoading: false
    ) {}
}
