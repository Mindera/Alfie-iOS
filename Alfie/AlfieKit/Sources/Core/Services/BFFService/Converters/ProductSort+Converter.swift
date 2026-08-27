import BFFGraph
import Foundation

extension BFFGraphAPI.ProductSortEnum {
    /// Maps the iOS UI sort selection (the `SortByType.rawValue` String surfaced by the
    /// Refine sheet) to the BFF's `ProductSortEnum`.
    ///
    /// Unknown or unrepresentable values — `nil`, which is the state before the user picks a
    /// sort, and any `Z_A` left in storage by an earlier release — fall back to `.newest`, the
    /// BFF's documented default sort.
    public static func from(sortOption: String?) -> BFFGraphAPI.ProductSortEnum {
        switch sortOption {
        case "HIGH_TO_LOW":
            return .priceDesc
        case "LOW_TO_HIGH":
            return .priceAsc
        case "A_Z":
            return .nameAsc
        default:
            return .newest
        }
    }
}
