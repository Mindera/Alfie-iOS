import Foundation
import Model

enum ThemedURL: String, WebURLEndpoint {
    case shop
    case brands = "brand"
    case services = "services/store-services"
    case paymentOptions = "payment-options"
    case returnOptions = "return-options"
}

extension ThemedURL {
    static let preferredHost = "localhost"
    static let port = "4000"
    static let internalScheme = "alfie"
    static let internalHost = "alfie.target"

    var internalUrl: URL? { // TODO: make this an app-local extension to WebURLEndpoint
        URL(string: "\(ThemedURL.internalScheme)://\(ThemedURL.internalHost)/\(self.path)")
    }

    static var hostWithPortComponent: String {
        ThemedURL.preferredHost + ":" + ThemedURL.port
    }
}
