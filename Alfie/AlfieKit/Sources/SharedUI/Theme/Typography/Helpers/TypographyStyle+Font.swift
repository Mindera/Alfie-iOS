import SwiftUI
import UIKit

// MARK: - UIFont.Weight from token weight

extension UIFont.Weight {
    /// Maps a design-token numeric weight (100...900) to the nearest standard `UIFont.Weight`.
    /// Tokens currently only use 400 (regular) and 500 (medium); anything else falls back to regular.
    public init(tokenWeight: Int) {
        switch tokenWeight {
        case 100: self = .ultraLight
        case 200: self = .thin
        case 300: self = .light
        case 400: self = .regular
        case 500: self = .medium
        case 600: self = .semibold
        case 700: self = .bold
        case 800: self = .heavy
        case 900: self = .black
        default: self = .regular
        }
    }
}

// MARK: - TypographyStyle -> UIFont bridge

extension TypographyStyle {
    /// The design-system name for the iOS system font. There's no named face to load via
    /// `UIFont(name:)`, so it resolves to `systemFont(ofSize:weight:)` (which also honours the token
    /// weight). Kept as a literal sentinel — NOT `Primitives.Typography.fontFamilyPrimaryIos` — so a
    /// theme that *overrides* its primary family to a real font still renders that font.
    private static let systemFontFamily = "SF Pro"

    /// Resolves a generated `TypographyStyle` token to a concrete `UIFont` from its `fontFamily`
    /// string — so a theme that swaps a font family (e.g. selfFridge) actually renders that font.
    /// - "SF Pro" → the dynamic system font at the token's weight.
    /// - A bundled face (e.g. "Libre Baskerville") loads via its PostScript name.
    /// - Any other family loads by its own name; if it can't be resolved the system font is used
    ///   (safe, never crashes).
    public var uiFont: UIFont {
        let systemFallback = UIFont.systemFont(ofSize: fontSize, weight: .init(tokenWeight: fontWeight))
        guard fontFamily != Self.systemFontFamily else { return systemFallback }
        let name = FontNames.postScriptName(forFamily: fontFamily) ?? fontFamily
        return UIFont(name: name, size: fontSize) ?? systemFallback
    }
}

// MARK: - AttributedString.build(style:)

extension AttributedString {
    /// Builds an `AttributedString` from a token style, delegating to the existing
    /// `build(font:lineHeight:letterSpacing:...)` so the line-height/kerning/RTL conventions are shared.
    public func build(
        style: TypographyStyle,
        underline: Bool = false,
        strike: Bool = false,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil
    ) -> AttributedString {
        build(
            font: style.uiFont,
            lineHeight: style.lineHeight,
            letterSpacing: style.letterSpacing,
            strike: strike,
            isUnderlined: underline,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor
        )
    }
}
