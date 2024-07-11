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
                return .init(backgroundColor: Colors.primary.mono900,
                             backgroundDisabledColor: Colors.primary.mono050,
                             backgroundPressedColor: Colors.primary.mono500,
                             textColor: .white,
                             textDisabledColor: Colors.primary.mono300,
                             textPressedColor: .white,
                             borderColor: Colors.primary.mono900,
                             borderDisabledColor: Colors.primary.mono050,
                             borderPressedColor: Colors.primary.mono500)
            case .secondary:
                return .init(backgroundColor: .white,
                             backgroundDisabledColor: .white,
                             backgroundPressedColor: Colors.primary.mono100,
                             textColor: Colors.primary.mono900,
                             textDisabledColor: Colors.primary.mono300,
                             textPressedColor: Colors.primary.mono500,
                             borderColor: Colors.primary.mono900,
                             borderDisabledColor: Colors.primary.mono300,
                             borderPressedColor: Colors.primary.mono500)
            case .tertiary:
                return .init(backgroundColor: .white,
                             backgroundDisabledColor: .white,
                             backgroundPressedColor: Colors.primary.mono100,
                             textColor: Colors.primary.mono900,
                             textDisabledColor: Colors.primary.mono300,
                             textPressedColor: Colors.primary.mono500,
                             borderColor: .white,
                             borderDisabledColor: .white,
                             borderPressedColor: Colors.primary.mono100)
            case .underline:
                return .init(backgroundColor: .white,
                             backgroundDisabledColor: .white,
                             backgroundPressedColor: .white,
                             textColor: Colors.primary.mono900,
                             textDisabledColor: Colors.primary.mono300,
                             textPressedColor: Colors.primary.mono500,
                             borderColor: .white,
                             borderDisabledColor: .white,
                             borderPressedColor: .white)
        }
    }
}
