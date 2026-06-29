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
    /// Resolves a generated `TypographyStyle` token to a concrete `UIFont`.
    /// - "SF Pro" (`fontFamilyPrimaryIos`) resolves to the dynamic system font — there is no
    ///   "SF Pro" named font to load via `UIFont(name:)`, so `systemFont(ofSize:weight:)` is used.
    /// - "Libre Baskerville" (`fontFamilyBrand`) resolves to the bundled brand face.
    /// - Any other family falls back to the system font (safe, never crashes).
    public var uiFont: UIFont {
        switch fontFamily {
        case Primitives.Typography.fontFamilyPrimaryIos:
            return .systemFont(ofSize: fontSize, weight: .init(tokenWeight: fontWeight))
        case Primitives.Typography.fontFamilyBrand:
            return FontNames.libreBaskerville.withSize(fontSize)
        default:
            return .systemFont(ofSize: fontSize, weight: .init(tokenWeight: fontWeight))
        }
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
