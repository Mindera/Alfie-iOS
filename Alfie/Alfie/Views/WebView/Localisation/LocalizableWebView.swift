import Foundation

struct LocalizableWebView: LocalizableProtocol {
    @LocalizableResource<Self>(.errorTitle) static var errorTitle
    @LocalizableResource<Self>(.errorGenericMessage) static var errorGenericMessage
    @LocalizableResource<Self>(.errorButtonLabel) static var errorButtonLabel
    @LocalizableResource<Self>(.returnOptionsFeatureTitle) static var returnOptionsFeatureTitle
    @LocalizableResource<Self>(.paymentOptionsFeatureTitle) static var paymentOptionsFeatureTitle
    @LocalizableResource<Self>(.storeServicesFeatureTitle) static var storeServicesFeatureTitle

    enum Keys: String, LocalizableKeyProtocol {
        case errorTitle = "KeyErrorTitle"
        case errorGenericMessage = "KeyErrorGenericMessage"
        case errorButtonLabel = "KeyErrorButtonLabel"
        case returnOptionsFeatureTitle = "KeyReturnOptionsFeatureTitle"
        case paymentOptionsFeatureTitle = "KeyPaymentOptionsFeatureTitle"
        case storeServicesFeatureTitle = "KeyStoreServicesFeatureTitle"
    }
}
