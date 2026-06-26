import Foundation
import SwiftUI

// MARK: - ButtonThemeSpec

struct ButtonThemeSpec {
    // Background specs
    var backgroundColor: Color
    var backgroundDisabledColor: Color
    var backgroundPressedColor: Color
    // Text specs
    var textColor: Color
    var textDisabledColor: Color
    var textPressedColor: Color
    // Border specs
    var borderColor: Color
    var borderDisabledColor: Color
    var borderPressedColor: Color
}

// MARK: - ButtonTheme

public enum ButtonTheme: String, CaseIterable {
    case primary
    case secondary
    case tertiary
    case underline

    var spec: ButtonThemeSpec {
        switch self {
        case .primary:
            return .init(
                backgroundColor: Primitives.Colours.neutrals800,
                backgroundDisabledColor: Primitives.Colours.neutrals100,
                backgroundPressedColor: Primitives.Colours.neutrals500,
                textColor: Primitives.Colours.neutrals0,
                textDisabledColor: Primitives.Colours.neutrals400,
                textPressedColor: Primitives.Colours.neutrals0,
                borderColor: Primitives.Colours.neutrals800,
                borderDisabledColor: Primitives.Colours.neutrals100,
                borderPressedColor: Primitives.Colours.neutrals500
            )

        case .secondary:
            return .init(
                backgroundColor: Primitives.Colours.neutrals0,
                backgroundDisabledColor: Primitives.Colours.neutrals0,
                backgroundPressedColor: Primitives.Colours.neutrals100,
                textColor: Primitives.Colours.neutrals800,
                textDisabledColor: Primitives.Colours.neutrals400,
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: Primitives.Colours.neutrals800,
                borderDisabledColor: Primitives.Colours.neutrals400,
                borderPressedColor: Primitives.Colours.neutrals500
            )

        case .tertiary:
            return .init(
                backgroundColor: Primitives.Colours.neutrals0,
                backgroundDisabledColor: Primitives.Colours.neutrals0,
                backgroundPressedColor: Primitives.Colours.neutrals100,
                textColor: Primitives.Colours.neutrals800,
                textDisabledColor: Primitives.Colours.neutrals400,
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: Primitives.Colours.neutrals0,
                borderDisabledColor: Primitives.Colours.neutrals0,
                borderPressedColor: Primitives.Colours.neutrals100
            )

        case .underline:
            return .init(
                backgroundColor: Primitives.Colours.neutrals0,
                backgroundDisabledColor: Primitives.Colours.neutrals0,
                backgroundPressedColor: Primitives.Colours.neutrals0,
                textColor: Primitives.Colours.neutrals800,
                textDisabledColor: Primitives.Colours.neutrals400,
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: Primitives.Colours.neutrals0,
                borderDisabledColor: Primitives.Colours.neutrals0,
                borderPressedColor: Primitives.Colours.neutrals0
            )
        }
    }
}
