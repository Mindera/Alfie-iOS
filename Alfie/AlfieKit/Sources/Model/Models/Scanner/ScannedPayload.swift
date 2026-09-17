import Foundation

public struct ScannedPayload: Equatable {
    public enum Symbology: Equatable {
        case qr
        case ean13
    }

    public let symbology: Symbology
    public let value: String

    public init(symbology: Symbology, value: String) {
        self.symbology = symbology
        self.value = value
    }

    public static func qr(_ value: String) -> Self {
        .init(symbology: .qr, value: value)
    }

    public static func ean13(_ value: String) -> Self {
        .init(symbology: .ean13, value: value)
    }
}
