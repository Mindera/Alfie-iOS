import AccessibilityIdentifiers
import SharedUI
import SwiftUI

// MARK: - ProductListingFilterChips

/// Horizontal row of filter chips shown under the PLP filter bar. The labels are mock stand-ins
/// for the server-driven filter facets (no filtering behaviour yet); selection is local-only.
struct ProductListingFilterChips: View {
    @State private var selected: Set<String> = []

    private let filters: [String]

    init(filters: [String] = Constants.mockFilters) {
        self.filters = filters
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.space100) {
                ForEach(filters, id: \.self) { label in
                    Chip(configuration: .init(
                        type: .small,
                        label: label,
                        isSelected: .constant(selected.contains(label))
                    ))
                    .onTapGesture { toggle(label) }
                    .accessibilityIdentifier(AccessibilityID.ProductListing.filterChip(label: label))
                }
            }
            .padding(.horizontal, theme.spacing.space200)
        }
        .accessibilityIdentifier(AccessibilityID.ProductListing.filterChips)
    }

    private func toggle(_ label: String) {
        if selected.contains(label) {
            selected.remove(label)
        } else {
            selected.insert(label)
        }
    }

    enum Constants {
        static let mockFilters = ["Slim Fit", "Linen", "Cotton", "Straight Fit", "Wool", "Regular Fit", "Silk"]
    }
}

#Preview {
    ProductListingFilterChips()
}
