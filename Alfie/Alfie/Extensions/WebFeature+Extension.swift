import Foundation
import Models

extension WebFeature {
    var title: String {
        switch self {
        case .returnOptions:
            return LocalizableWebView.$returnOptionsFeatureTitle

        case .paymentOptions:
            return LocalizableWebView.$paymentOptionsFeatureTitle

        case .storeServices:
            return LocalizableWebView.$storeServicesFeatureTitle

        default:
            assertionFailure("No title string defined for WebFeature \(self)")
            return ""
        }
    }
}
