import Foundation
import Models

extension WebFeature {
    var title: String {
        switch self {
        case .returnOptions:
            return L10n.$webViewReturnOptionsFeatureTitle

        case .paymentOptions:
            return L10n.$webViewPaymentOptionsFeatureTitle

        case .storeServices:
            return L10n.$webViewStoreServicesFeatureTitle

        default:
            assertionFailure("No title string defined for WebFeature \(self)")
            return ""
        }
    }
}
