import Foundation

public enum ThemedURL2: String, WebURLEndpoint {
    case shop
    case brands = "brand"
    case services = "services/store-services"
    case paymentOptions = "payment-options"
    case returnOptions = "return-options"
}

public extension ThemedURL2 {
    static let preferredHost = "localhost"
    static let port = "4000"
    static let internalScheme = "alfie"
    static let internalHost = "alfie.target"

    var internalUrl: URL? { // TODO: make this an app-local extension to WebURLEndpoint
        URL(string: "\(ThemedURL2.internalScheme)://\(ThemedURL2.internalHost)/\(self.path)")
    }

    static var hostWithPortComponent: String {
        ThemedURL2.preferredHost + ":" + ThemedURL2.port
    }
}
