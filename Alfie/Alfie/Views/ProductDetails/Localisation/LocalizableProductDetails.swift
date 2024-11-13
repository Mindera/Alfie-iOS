import Foundation

struct LocalizableProductDetails: LocalizableProtocol {
    @LocalizableResource<Self>(.complementaryInfoDelivery) static var complementaryInfoDelivery
    @LocalizableResource<Self>(.complementaryInfoPayment) static var complementaryInfoPayment
    @LocalizableResource<Self>(.complementaryInfoReturns) static var complementaryInfoReturns
    @LocalizableResource<Self>(.productDescription) static var productDescription
    @LocalizableResource<Self>(.addToBag) static var addToBag
    @LocalizableResource<Self>(.addToWishlist) static var addToWishlist
    @LocalizableResource<Self>(.outOfStock) static var outOfStock
    @LocalizableResource<Self>(.shareTitleFrom) static var shareTitleFrom
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorNotFoundMessage) static var errorNotFoundMessage
    @LocalizableResource<Self>(.errorGenericMessage) static var errorGenericMessage
    @LocalizableResource<Self>(.errorButtonBackLabel) static var errorButtonBackLabel
    @LocalizableResource<Self>(.color) static var color
    @LocalizableResource<Self>(.searchColors) static var searchColors
    @LocalizableResource<Self>(.size) static var size
    @LocalizableResource<Self>(.oneSize) static var oneSize

    enum Keys: String, LocalizableKeyProtocol {
        case complementaryInfoDelivery = "KeyComplementaryInfoDelivery"
        case complementaryInfoPayment = "KeyComplementaryInfoPayment"
        case complementaryInfoReturns = "KeyComplementaryInfoReturns"
        case productDescription = "KeyProductDescription"
        case addToBag = "KeyAddToBag"
        case addToWishlist = "KeyAddToWishlist"
        case outOfStock = "KeyOutOfStock"
        case shareTitleFrom = "KeyShareTitleFrom"
        case errorTitle = "KeyErrorTitle"
        case errorNotFoundMessage = "KeyErrorNotFoundMessage"
        case errorGenericMessage = "KeyErrorGenericMessage"
        case errorButtonBackLabel = "KeyErrorButtonBackLabel"
        case color = "KeyColor"
        case searchColors = "KeySearchColors"
        case size = "KeySize"
        case oneSize = "KeyOneSize"
    }
}
