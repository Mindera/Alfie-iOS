import Foundation
import Model
import SharedUI

public extension WebFeature {
    var title: String {
        switch self {
        case .returnOptions:
            return L10n.WebView.ReturnOptionsFeature.title

        case .paymentOptions:
            return L10n.WebView.PaymentOptionsFeature.title

        case .storeServices:
            return L10n.WebView.StoreServicesFeature.title

        default:
            assertionFailure("No title string defined for WebFeature \(self)")
            return ""
        }
    }
}
