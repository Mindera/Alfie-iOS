import Foundation

public enum ProductDetailsSection {
    case titleHeader
    case colorSelector
    case sizeSelector
    /// The note qualifying what the colour and size selectors' availability actually means.
    case availabilityNote
    case mediaCarousel
    case complementaryInfo
    case productDescription
    case addToBag
    case addToWishlist
}
