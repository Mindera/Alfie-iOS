import SwiftUI
import class UIKit.UIFont

// MARK: - TypographyStyle → Font

extension TypographyStyle {
    /// UIKit font built from the token's family, weight and size.
    public var uiFont: UIFont {
        // SF Pro is the system typeface: `systemFont(ofSize:weight:)` resolves the numeric token
        // weight against the installed system faces without needing a bundled font file. Any other
        // (e.g. future brand) family is looked up by name — where the face itself carries the weight.
        if fontFamily == Primitives.Typography.fontFamilyPrimaryIos {
            return .systemFont(ofSize: fontSize, weight: uiFontWeight)
        }
        return UIFont(name: fontFamily, size: fontSize)
            ?? .systemFont(ofSize: fontSize, weight: uiFontWeight)
    }

    /// SwiftUI font built from the token.
    public var font: Font {
        uiFont.font
    }

    /// Maps a numeric (CSS-style) token weight onto the nearest `UIFont.Weight` bucket.
    private var uiFontWeight: UIFont.Weight {
        switch fontWeight {
        case ..<150: return .ultraLight
        case ..<250: return .thin
        case ..<350: return .light
        case ..<450: return .regular
        case ..<550: return .medium
        case ..<650: return .semibold
        case ..<750: return .bold
        case ..<850: return .heavy
        default: return .black
        }
    }
}
