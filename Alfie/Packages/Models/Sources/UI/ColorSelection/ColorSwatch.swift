import SwiftUI

// MARK: - SwatchType

public enum SwatchType: Equatable {
    case image(Image)
    case color(Color)
    case url(URL)

    public static func == (lhs: SwatchType, rhs: SwatchType) -> Bool {
        // swiftlint:disable vertical_whitespace_between_cases
        switch (lhs, rhs) {
        case (.image(let imagel), .image(let imager)):
            return imagel == imager
        case (.color(let colorl), .color(let colorr)):
            return colorl == colorr
        case (.url(let urll), .url(let urlr)):
            return urll == urlr
        default:
            return false
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

// MARK: - ColorSwatch

public struct ColorSwatch: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let type: SwatchType
    public let isDisabled: Bool

    public init(id: String = UUID().uuidString, name: String, type: SwatchType, isDisabled: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.isDisabled = isDisabled
    }

    public static func == (lhs: ColorSwatch, rhs: ColorSwatch) -> Bool {
        lhs.id == rhs.id
    }
}
