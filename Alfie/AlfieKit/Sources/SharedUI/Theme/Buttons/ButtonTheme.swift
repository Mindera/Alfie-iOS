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

public enum ButtonTheme: String, CaseIterable, ThemeReading {
    case primary
    case secondary
    case tertiary
    case underline

    var spec: ButtonThemeSpec {
        switch self {
        case .primary:
            return .init(
                backgroundColor: theme.color.buttonPrimaryBackgroundPrimaryDefault,
                backgroundDisabledColor: theme.color.buttonPrimaryBackgroundPrimaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                backgroundPressedColor: Primitives.Colours.neutrals500,
                textColor: theme.color.buttonPrimaryContentPrimaryDefault,
                textDisabledColor: theme.color.buttonPrimaryContentPrimaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                textPressedColor: Primitives.Colours.neutrals0,
                borderColor: theme.color.buttonPrimaryStrokePrimaryDefault,
                borderDisabledColor: theme.color.buttonPrimaryStrokePrimaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                borderPressedColor: Primitives.Colours.neutrals500
            )

        case .secondary:
            return .init(
                backgroundColor: theme.color.buttonSecondaryBackgroundSecondaryDefault,
                backgroundDisabledColor: theme.color.buttonSecondaryBackgroundSecondaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                backgroundPressedColor: Primitives.Colours.neutrals100,
                textColor: theme.color.buttonSecondaryContentSecondaryDefault,
                textDisabledColor: theme.color.buttonSecondaryContentSecondaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: theme.color.buttonSecondaryStrokeSecondaryDefault,
                borderDisabledColor: theme.color.buttonSecondaryStrokeSecondaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                borderPressedColor: Primitives.Colours.neutrals500
            )

        case .tertiary:
            return .init(
                backgroundColor: theme.color.buttonTerciaryBackgroundTerciaryDefault,
                backgroundDisabledColor: theme.color.buttonTerciaryBackgroundTerciaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                backgroundPressedColor: Primitives.Colours.neutrals100,
                textColor: theme.color.buttonTerciaryContentTerciaryDefault,
                textDisabledColor: theme.color.buttonTerciaryContentTerciaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: theme.color.buttonTerciaryStrokeTerciaryDefault,
                borderDisabledColor: theme.color.buttonTerciaryStrokeTerciaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                borderPressedColor: Primitives.Colours.neutrals100
            )

        case .underline:
            return .init(
                backgroundColor: theme.color.buttonTerciaryBackgroundTerciaryDefault,
                backgroundDisabledColor: theme.color.buttonTerciaryBackgroundTerciaryDisabled,
                backgroundPressedColor: theme.color.buttonTerciaryBackgroundTerciaryDefault,
                textColor: theme.color.linkLinkPrimaryDefault,
                textDisabledColor: theme.color.linkLinkPrimaryDisabled,
                // swiftlint:disable:next no_primitive_tokens - design review #186: no button pressed token
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: theme.color.buttonTerciaryStrokeTerciaryDefault,
                borderDisabledColor: theme.color.buttonTerciaryStrokeTerciaryDisabled,
                borderPressedColor: theme.color.buttonTerciaryStrokeTerciaryDefault
            )
        }
    }
}
