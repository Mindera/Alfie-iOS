import Foundation

public struct ScannedPayload: Equatable {
    public enum Symbology: Equatable {
        case qr
        case ean13
        /// Selfridges tags carry their GTIN-13 in a Code 128 symbol rather than an EAN-13 one, so
        /// this is a product barcode too — the symbology differs, the value it carries does not.
        case code128
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

    public static func code128(_ value: String) -> Self {
        .init(symbology: .code128, value: value)
    }
}
