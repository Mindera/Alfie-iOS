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
        // Default/disabled colors come from the semantic `Theme.button*` tokens; the pressed state
        // has no semantic token, so it stays on `Primitives.Colours.*`.
        case .primary:
            return .init(
                backgroundColor: Theme.buttonPrimaryBackgroundPrimaryDefault,
                backgroundDisabledColor: Theme.buttonPrimaryBackgroundPrimaryDisabled,
                backgroundPressedColor: Primitives.Colours.neutrals500,
                textColor: Theme.buttonPrimaryContentPrimaryDefault,
                textDisabledColor: Theme.buttonPrimaryContentPrimaryDisabled,
                textPressedColor: Primitives.Colours.neutrals0,
                borderColor: Theme.buttonPrimaryStrokePrimaryDefault,
                borderDisabledColor: Theme.buttonPrimaryStrokePrimaryDisabled,
                borderPressedColor: Primitives.Colours.neutrals500
            )

        case .secondary:
            return .init(
                backgroundColor: Theme.buttonSecondaryBackgroundSecondaryDefault,
                backgroundDisabledColor: Theme.buttonSecondaryBackgroundSecondaryDisabled,
                backgroundPressedColor: Primitives.Colours.neutrals100,
                textColor: Theme.buttonSecondaryContentSecondaryDefault,
                textDisabledColor: Theme.buttonSecondaryContentSecondaryDisabled,
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: Theme.buttonSecondaryStrokeSecondaryDefault,
                borderDisabledColor: Theme.buttonSecondaryStrokeSecondaryDisabled,
                borderPressedColor: Primitives.Colours.neutrals500
            )

        case .tertiary:
            return .init(
                backgroundColor: Theme.buttonTerciaryBackgroundTerciaryDefault,
                backgroundDisabledColor: Theme.buttonTerciaryBackgroundTerciaryDisabled,
                backgroundPressedColor: Primitives.Colours.neutrals100,
                textColor: Theme.buttonTerciaryContentTerciaryDefault,
                textDisabledColor: Theme.buttonTerciaryContentTerciaryDisabled,
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: Theme.buttonTerciaryStrokeTerciaryDefault,
                borderDisabledColor: Theme.buttonTerciaryStrokeTerciaryDisabled,
                borderPressedColor: Primitives.Colours.neutrals100
            )

        // Underline has no semantic button group → its text tracks the semantic `Theme.linkLink*`
        // tokens (an underline button is a link); pressed text and the invisible background/border
        // have no matching token and stay on `Primitives.Colours.*`.
        case .underline:
            return .init(
                backgroundColor: Primitives.Colours.neutrals0,
                backgroundDisabledColor: Primitives.Colours.neutrals0,
                backgroundPressedColor: Primitives.Colours.neutrals0,
                textColor: Theme.linkLinkPrimaryDefault,
                textDisabledColor: Theme.linkLinkPrimaryDisabled,
                textPressedColor: Primitives.Colours.neutrals500,
                borderColor: Primitives.Colours.neutrals0,
                borderDisabledColor: Primitives.Colours.neutrals0,
                borderPressedColor: Primitives.Colours.neutrals0
            )
        }
    }
}
