import Foundation
import SwiftUI

// MARK: - ButtonThemeSpec

struct ButtonThemeSpec {
    // Background specs
    var backgroundColor: Color
    var backgroundDisabledColor: Color
    // Text specs
    var textColor: Color
    var textDisabledColor: Color
    // Border specs
    var borderColor: Color
    var borderDisabledColor: Color
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
                textColor: theme.color.buttonPrimaryContentPrimaryDefault,
                textDisabledColor: theme.color.buttonPrimaryContentPrimaryDisabled,
                borderColor: theme.color.buttonPrimaryStrokePrimaryDefault,
                borderDisabledColor: theme.color.buttonPrimaryStrokePrimaryDisabled
            )

        case .secondary:
            return .init(
                backgroundColor: theme.color.buttonSecondaryBackgroundSecondaryDefault,
                backgroundDisabledColor: theme.color.buttonSecondaryBackgroundSecondaryDisabled,
                textColor: theme.color.buttonSecondaryContentSecondaryDefault,
                textDisabledColor: theme.color.buttonSecondaryContentSecondaryDisabled,
                borderColor: theme.color.buttonSecondaryStrokeSecondaryDefault,
                borderDisabledColor: theme.color.buttonSecondaryStrokeSecondaryDisabled
            )

        case .tertiary:
            return .init(
                backgroundColor: theme.color.buttonTerciaryBackgroundTerciaryDefault,
                backgroundDisabledColor: theme.color.buttonTerciaryBackgroundTerciaryDisabled,
                textColor: theme.color.buttonTerciaryContentTerciaryDefault,
                textDisabledColor: theme.color.buttonTerciaryContentTerciaryDisabled,
                borderColor: theme.color.buttonTerciaryStrokeTerciaryDefault,
                borderDisabledColor: theme.color.buttonTerciaryStrokeTerciaryDisabled
            )

        case .underline:
            return .init(
                backgroundColor: theme.color.buttonTerciaryBackgroundTerciaryDefault,
                backgroundDisabledColor: theme.color.buttonTerciaryBackgroundTerciaryDisabled,
                textColor: theme.color.linkLinkPrimaryDefault,
                textDisabledColor: theme.color.linkLinkPrimaryDisabled,
                borderColor: theme.color.buttonTerciaryStrokeTerciaryDefault,
                borderDisabledColor: theme.color.buttonTerciaryStrokeTerciaryDisabled
            )
        }
    }
}
