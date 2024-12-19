import Foundation

// MARK: - SortByType

public enum SortByType: String, Hashable {
    case priceHighToLow = "HIGH_TO_LOW"
    case priceLowToHigh = "LOW_TO_HIGH"
    case alphaAsc = "A_Z"
    case alphaDesc = "Z_A"
}
