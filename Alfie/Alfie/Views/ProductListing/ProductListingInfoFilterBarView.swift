import Models
import StyleGuide
import SwiftUI

// MARK: - ProductListingFilterBarView

struct ProductListingFilterBarView: View {
    @Binding private var styleSelected: ProductListingListStyle
    @State private var opacity: CGFloat = .zero
    private var isLoading: () -> Bool
    private var total: Int
    private var filterAction: () -> Void

    public init(_ style: Binding<ProductListingListStyle>, total: Int, isLoading: @escaping () -> Bool, filterAction: @escaping () -> Void) {
        _styleSelected = style
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
            listTypeView
        }
        .onChange(of: isLoading()) { newValue in
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
                    .resizable()
                    .renderingMode(.template)
                    .frame(size: Constants.filterIcon)
                    .tint(Colors.primary.mono900)
                Text.build(theme.font.paragraph.normal(LocalizableProductListing.filters))
                    .foregroundStyle(Colors.primary.mono900)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityId.filterButton)
    }

    private var resultInfoView: some View {
        Text.build(theme.font.tiny.normal(LocalizableProductListing.results(total)))
            .foregroundStyle(Colors.primary.mono500)
            .accessibilityIdentifier(AccessibilityId.resultsLabel)
    }

    private var listTypeView: some View {
        HStack(spacing: Spacing.space200) {
            Button {
                styleSelected = .grid
            } label: {
                Icon.grid.image
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.filterIcon, height: Constants.filterIcon)
                    .foregroundStyle(styleSelected == .grid ? Colors.primary.mono900 : Colors.primary.mono200)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityId.listTypeGridButton)
            Button {
                styleSelected = .list
            } label: {
                Icon.listplp.image
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.filterIcon, height: Constants.filterIcon)
                    .foregroundStyle(styleSelected == .list ? Colors.primary.mono900 : Colors.primary.mono200)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityId.listTypeListButton)
        }
    }

    private enum Constants {
        static let fullOpacityResults: CGFloat = 1
        static let barMinHeight: CGFloat = 60.0
        static let filterIcon: CGFloat = 16.0
    }
}

// MARK: - Accessibility Id's

private enum AccessibilityId {
    static let filterButton = "filter-btn"
    static let resultsLabel = "results-lbl"
    static let listTypeGridButton = "grid-btn"
    static let listTypeListButton = "single-column-btn"
}

#Preview {
    ProductListingFilterBarView(.constant(.grid), total: 122, isLoading: { false }, filterAction: {})
}
