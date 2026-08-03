import AccessibilityIdentifiers
import SharedUI
import SwiftUI

// MARK: - ProductListingFilterChips

/// Horizontal row of filter chips shown under the PLP filter bar. The labels are mock stand-ins for
/// the (not-yet-available) server-driven filter facets; selection is local-only, with no filtering
/// behaviour. Replace `mockFilters` + the local selection with the real facets once the BFF exposes them.
struct ProductListingFilterChips: View {
    @State private var selectedIDs: Set<String> = []

    // Mock facets carry a stable id (mirrors the shape of the future server-driven facets), so the
    // selection state and accessibility identifiers survive reordering and the swap to real data.
    private let filters: [(id: String, label: String)] = [
        (id: "slim-fit", label: "Slim Fit"),
        (id: "linen", label: "Linen"),
        (id: "cotton", label: "Cotton"),
        (id: "straight-fit", label: "Straight Fit"),
        (id: "wool", label: "Wool"),
        (id: "regular-fit", label: "Regular Fit"),
        (id: "silk", label: "Silk"),
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.space100) {
                ForEach(filters, id: \.id) { filter in
                    let isSelected = selectedIDs.contains(filter.id)
                    Chip(configuration: .init(type: .small, label: filter.label, isSelected: .constant(isSelected)))
                        .contentShape(Rectangle())
                        .onTapGesture { toggle(filter.id) }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .accessibilityIdentifier(AccessibilityID.ProductListing.filterChip(id: filter.id))
                }
            }
            .padding(.horizontal, theme.spacing.space200)
        }
        .accessibilityIdentifier(AccessibilityID.ProductListing.filterChips)
    }

    private func toggle(_ id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

#Preview {
    ProductListingFilterChips()
}
