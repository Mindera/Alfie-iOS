import Foundation

struct LocalizableProductDetails: LocalizableProtocol {
    @LocalizableResource<Self>(.complementaryInfoDelivery) static var complementaryInfoDelivery
    @LocalizableResource<Self>(.complementaryInfoPayment) static var complementaryInfoPayment
    @LocalizableResource<Self>(.complementaryInfoReturns) static var complementaryInfoReturns
    @LocalizableResource<Self>(.productDescription) static var productDescription
    @LocalizableResource<Self>(.shareTitleFrom) static var shareTitleFrom
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorNotFoundMessage) static var errorNotFoundMessage
    @LocalizableResource<Self>(.errorGenericMessage) static var errorGenericMessage
    @LocalizableResource<Self>(.errorButtonBackLabel) static var errorButtonBackLabel
    @LocalizableResource<Self>(.searchColors) static var searchColors

    enum Keys: String, LocalizableKeyProtocol {
        case complementaryInfoDelivery = "KeyComplementaryInfoDelivery"
        case complementaryInfoPayment = "KeyComplementaryInfoPayment"
        case complementaryInfoReturns = "KeyComplementaryInfoReturns"
        case productDescription = "KeyProductDescription"
        case shareTitleFrom = "KeyShareTitleFrom"
        case errorTitle = "KeyErrorTitle"
        case errorNotFoundMessage = "KeyErrorNotFoundMessage"
        case errorGenericMessage = "KeyErrorGenericMessage"
        case errorButtonBackLabel = "KeyErrorButtonBackLabel"
        case searchColors = "KeySearchColors"
    }
}
