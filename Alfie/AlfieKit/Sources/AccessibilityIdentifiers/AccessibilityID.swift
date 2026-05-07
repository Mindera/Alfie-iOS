import Foundation

/// Centralised registry of accessibility identifiers used across the app and
/// consumed by UI tests. Identifiers follow the convention:
///
///     screen.component[.subcomponent].type
///
/// Use static constants for fixed elements and pure functions for dynamic ones
/// (always derived from a stable model id, never from an array index).
public enum AccessibilityID {

    // MARK: - ProductListing

    public enum ProductListing {
        public static let screen = "productListing"
        public static let filterButton = "productListing.filter.button"
        public static let resultsLabel = "productListing.results.label"
        public static let listStyleGridButton = "productListing.listStyle.grid.button"
        public static let listStyleListButton = "productListing.listStyle.list.button"

        public static func row(id: String) -> String {
            "productListing.row.\(id)"
        }
    }
}
