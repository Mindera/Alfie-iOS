import Foundation

// MARK: - SortByType

public enum SortByType: String, Hashable {
    case priceDesc = "HIGH_TO_LOW"
    case priceAsc = "LOW_TO_HIGH"
    case alphaAsc = "A_Z"
    case alphaDesc = "Z_A"
}
