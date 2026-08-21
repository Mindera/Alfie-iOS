import AccessibilityIdentifiers
import Combine
import Model
import SharedUI
import SwiftUI

struct ProductListingFilter: View {
    /// Scoped to this sheet rather than added to `ProductListingRoute`: the refine surface is
    /// presented *over* the PLP stack, so its sub-screens are not flow-level navigation and must
    /// not share the PLP's push stack (ALFMOB-476).
    private enum RefineRoute: Hashable {
        case price
        case sort
    }

    @StateObject private var viewModel: RefineViewModel
    @Binding private var listStyle: ProductListingListStyle
    @Binding private var isVisible: Bool
    @State private var path: [RefineRoute] = []

    init(
        isVisible: Binding<Bool>,
        listStyle: Binding<ProductListingListStyle>,
        priceBounds: PriceFilterBounds?,
        appliedFilters: ProductFilterInput?,
        appliedSort: SortByType?,
        onApply: @escaping (ProductFilterInput?, SortByType?) -> Void
    ) {
        self._isVisible = isVisible
        self._listStyle = listStyle
        self._viewModel = StateObject(
            wrappedValue: RefineViewModel(
                priceBounds: priceBounds,
                appliedFilters: appliedFilters,
                appliedSort: appliedSort,
                onApply: onApply
            )
        )
    }

    var body: some View {
        // The CTA lives outside the stack so it is pinned across every screen as one instance —
        // duplicating it per screen would put two identical accessibility ids in the hierarchy.
        VStack(spacing: theme.spacing.space0) {
            NavigationStack(path: $path) {
                root
                    .navigationDestination(for: RefineRoute.self) { route in
                        destination(for: route)
                    }
            }
            applyButton
        }
        .presentationDetents([.large])
        .accessibilityIdentifier(AccessibilityID.ProductListing.refineSheet)
    }

    // MARK: - Root

    private var root: some View {
        VStack(spacing: theme.spacing.space100) {
            header
            ThemedDivider.horizontalThin
            VStack(spacing: theme.spacing.space300) {
                listStyleView
                rows
            }
            .padding(.vertical, theme.spacing.space200)
            Spacer()
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Button {
                isVisible = false
            } label: {
                ThemedIcon(
                    .close,
                    size: .medium,
                    tint: Theme.contentContentPrimary,
                    accessibilityLabel: L10n.Accessibility.close
                )
            }
            .accessibilityIdentifier(AccessibilityID.ProductListing.refineCloseButton)

            Spacer()
            ThemedToolbarTitle(style: .text(L10n.Plp.RefineAndSort.title))
            Spacer()
            removeAllButton(accessibilityIdentifier: AccessibilityID.ProductListing.refineRemoveAllButton)
        }
        .padding(.horizontal, theme.spacing.space300)
    }

    /// Figma places Remove All on both the panel and the sub-screen headers. With one filterable
    /// dimension the two are the same operation (ALFMOB-486), so they share behaviour but carry
    /// distinct identifiers — both can be in the hierarchy at once while a sub-screen is pushed.
    @ViewBuilder private func removeAllButton(accessibilityIdentifier: String) -> some View {
        // Hidden rather than disabled while there is nothing to remove (ALFMOB-486 left the
        // visual state to implementation).
        if viewModel.hasActiveFilters {
            Button {
                viewModel.removeAllFilters()
            } label: {
                Text.build(theme.font.body.small(L10n.Plp.Refine.RemoveAll.Button.cta))
                    .foregroundStyle(Theme.linkLinkPrimaryDefault)
            }
            .accessibilityIdentifier(accessibilityIdentifier)
        }
    }

    /// v1 exposes Price and Sort only. Every row here does something — a dimension that cannot be
    /// filtered gets no row at all, not a disabled one or an empty screen (ALFMOB-477 / 483).
    @ViewBuilder private var rows: some View {
        VStack(spacing: theme.spacing.space0) {
            // No bounds means no scale to filter within — which is also the search-driven PLP,
            // where `categoryPriceRange` has no collection handle to key on.
            if viewModel.priceBounds != nil {
                row(
                    title: L10n.Plp.Refine.Price.Option.title,
                    value: viewModel.priceSummary,
                    route: .price,
                    accessibilityIdentifier: AccessibilityID.ProductListing.refinePriceRow
                )
                ThemedDivider.horizontalThin
            }
            row(
                title: L10n.Plp.SortBy.Option.title,
                value: sortSummary,
                route: .sort,
                accessibilityIdentifier: AccessibilityID.ProductListing.refineSortRow
            )
        }
    }

    private func row(
        title: String,
        value: String?,
        route: RefineRoute,
        accessibilityIdentifier: String
    ) -> some View {
        Button {
            path.append(route)
        } label: {
            HStack(spacing: theme.spacing.space100) {
                Text.build(theme.font.body.medium(title))
                    .foregroundStyle(Theme.contentContentPrimary)
                Spacer()
                if let value {
                    Text.build(theme.font.body.small(value))
                        .foregroundStyle(Theme.contentContentTerciary)
                }
                ThemedIcon(.chevronRight, size: .small, tint: Theme.contentContentPrimary)
            }
            .padding(.horizontal, theme.spacing.space200)
            .frame(height: Constants.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityAddTraits(.isButton)
    }

    private var applyButton: some View {
        ThemedButton(text: L10n.Plp.ShowResults.Button.cta) {
            viewModel.apply()
        }
        .disabled(!viewModel.canApply)
        .accessibilityIdentifier(AccessibilityID.ProductListing.refineApplyButton)
    }

    private var listStyleView: some View {
        HStack {
            Text.build(theme.font.body.medium(L10n.Plp.ListStyle.Option.title))
                .foregroundStyle(Theme.contentContentPrimary)
            Spacer()
            ProductListingListStyleSelector(selectedStyle: $listStyle)
        }
        .padding(.horizontal, theme.spacing.space200)
    }

    // MARK: - Sub-screens

    @ViewBuilder private func destination(for route: RefineRoute) -> some View {
        Group {
            switch route {
            case .price:
                if let bounds = viewModel.priceBounds {
                    RefinePriceView(viewModel: viewModel, bounds: bounds)
                }

            case .sort:
                SortByView(
                    sortBy: $viewModel.pendingSort,
                    title: L10n.Plp.SortBy.Option.title,
                    options: SortByHelper.options
                )
                .padding(.top, theme.spacing.space300)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle(title(for: route))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                removeAllButton(
                    accessibilityIdentifier: AccessibilityID.ProductListing.refineSubscreenRemoveAllButton
                )
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Back is navigation only — pending edits stand, and nothing is committed
                    // until the CTA (ALFMOB-476).
                    guard !path.isEmpty else { return }
                    path.removeLast()
                } label: {
                    ThemedIcon(
                        .chevronLeft,
                        size: .medium,
                        tint: Theme.contentContentPrimary,
                        accessibilityLabel: L10n.Accessibility.back
                    )
                }
                .accessibilityIdentifier(AccessibilityID.ProductListing.refineBackButton)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func title(for route: RefineRoute) -> String {
        switch route {
        case .price:
            return L10n.Plp.Refine.Price.Option.title
        case .sort:
            return L10n.Plp.SortBy.Option.title
        }
    }

    private var sortSummary: String? {
        SortByHelper.options.first { $0.value == viewModel.pendingSort }?.title
    }

    private enum Constants {
        static let rowHeight: CGFloat = 56
    }
}

#Preview {
    ProductListingFilter(
        isVisible: .constant(true),
        listStyle: .constant(.grid),
        priceBounds: .init(currencyCode: "GBP", minimum: 8, maximum: 480),
        appliedFilters: nil,
        appliedSort: nil,
        onApply: { _, _ in }
    )
}
