import SwiftUI
import UIKit

// MARK: - ThemedTypographyStyle

/// A token style wrapped for the theme provider surface. Callable as a function to build an
/// `AttributedString`, and exposes `.uiFont` for UIKit/`Font(...)`/`.withSize` integration points.
public struct ThemedTypographyStyle {
    public let style: TypographyStyle

    public init(style: TypographyStyle) {
        self.style = style
    }

    public var uiFont: UIFont { style.uiFont }

    /// String-only overload — L10n is `String`-typed, so no `LocalizedStringResource` overload exists
    /// (a second trailing-default overload would be an ambiguity trap).
    public func callAsFunction(_ string: String, underline: Bool = false, strike: Bool = false) -> AttributedString {
        AttributedString(string).build(style: style, underline: underline, strike: strike)
    }
}
