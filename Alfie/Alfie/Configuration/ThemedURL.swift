import Foundation
import Models

enum ThemedURL: String, WebURLEndpoint {
    case shop
    case brands = "brand"
    case services = "services/store-services"
    case paymentOptions = "payment-options"
    case returnOptions = "return-options"
}

extension ThemedURL {
    static let preferredHost = "localhost:4000"
    static let internalScheme = "alfie"
    static let internalHost = "alfie.target"

    var internalUrl: URL? { // TODO: make this an app-local extension to WebURLEndpoint
        URL(string: "\(ThemedURL.internalScheme)://\(ThemedURL.internalHost)/\(self.path)")
    }
}
