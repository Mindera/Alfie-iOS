import BFFGraph
import Foundation

extension BFFGraphAPI.ProductSortEnum {
    /// Maps the iOS UI sort selection (the `SortByType.rawValue` String surfaced by the
    /// Refine sheet) to the BFF's `ProductSortEnum`.
    ///
    /// Unknown or unrepresentable values — including `nil` and the legacy `Z_A` option,
    /// which has no `NAME_DESC` equivalent on the BFF yet — fall back to `.newest`, the
    /// BFF's documented default sort.
    public static func from(sortOption: String?) -> BFFGraphAPI.ProductSortEnum {
        switch sortOption {
        case "HIGH_TO_LOW":
            return .priceDesc
        case "LOW_TO_HIGH":
            return .priceAsc
        case "A_Z":
            return .nameAsc
        case "Z_A":
            // TODO: BFF doesn't yet expose `NAME_DESC`. Falling back to `NEWEST` until the
            // BFF team adds the enum case (tracked separately with the BFF team).
            return .newest
        default:
            return .newest
        }
    }
}
