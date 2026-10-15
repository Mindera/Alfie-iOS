import Foundation

public enum ThemedURL: String, WebURLEndpoint {
    case shop
    case paymentOptions = "payment-options"
    case returnOptions = "return-options"
}

public extension ThemedURL {
    static let preferredHost = "localhost"
    static let port = "4000"
    static let internalScheme = "alfie"
    static let internalHost = "alfie.target"

    static var hostWithPortComponent: String {
        ThemedURL.preferredHost + ":" + ThemedURL.port
    }
}
