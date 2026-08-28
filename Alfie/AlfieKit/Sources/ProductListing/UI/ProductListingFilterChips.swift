import AccessibilityIdentifiers
import SharedUI
import SwiftUI

// MARK: - ProductListingFilterChips

/// Horizontal row of filter chips shown under the PLP filter bar. The labels are mock stand-ins for
/// the (not-yet-available) server-driven filter facets; selection is local-only, with no filtering
/// behaviour. Replace `mockFilters` + the local selection with the real facets once the BFF exposes them.
struct ProductListingFilterChips: View {
    @State private var selectedIndices: Set<Int> = []

    // Localised even though the row is mocked: these render on every PLP, so shipping raw English
    // would break the project's no-hardcoded-strings rule for real users. The eventual facet model
    // supplies its own display text and these keys go with it.
    private let filters = [
        L10n.Plp.QuickFilter.SlimFit.label,
        L10n.Plp.QuickFilter.Linen.label,
        L10n.Plp.QuickFilter.Cotton.label,
        L10n.Plp.QuickFilter.StraightFit.label,
        L10n.Plp.QuickFilter.Wool.label,
        L10n.Plp.QuickFilter.RegularFit.label,
        L10n.Plp.QuickFilter.Silk.label,
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.space100) {
                ForEach(Array(filters.enumerated()), id: \.offset) { index, label in
                    let isSelected = selectedIndices.contains(index)
                    Chip(configuration: .init(type: .small, label: label, isSelected: .constant(isSelected)))
                        .contentShape(Rectangle())
                        .onTapGesture { toggle(index) }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .accessibilityIdentifier(AccessibilityID.ProductListing.filterChip(index: index))
                }
            }
            .padding(.horizontal, theme.spacing.space200)
        }
        .accessibilityIdentifier(AccessibilityID.ProductListing.filterChips)
    }

    private func toggle(_ index: Int) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
    }
}

#Preview {
    ProductListingFilterChips()
}
