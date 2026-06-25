import SwiftUI

// MARK: - ColorProviderProtocol

/// Colour palette, forwarded from the generated `Primitives.Colours` tokens. Vended through
/// `DesignSystem` so the palette can be swapped/injected as part of the theme.
public protocol ColorProviderProtocol {
    var neutrals0: Color { get }
    var neutrals100: Color { get }
    var neutrals200: Color { get }
    var neutrals300: Color { get }
    var neutrals400: Color { get }
    var neutrals500: Color { get }
    var neutrals600: Color { get }
    var neutrals700: Color { get }
    var neutrals800: Color { get }
    var neutrals900: Color { get }
    var semanticSuccess100: Color { get }
    var semanticSuccess200: Color { get }
    var semanticSuccess300: Color { get }
    var semanticSuccess400: Color { get }
    var semanticSuccess500: Color { get }
    var semanticSuccess600: Color { get }
    var semanticSuccess700: Color { get }
    var semanticSuccess800: Color { get }
    var semanticError100: Color { get }
    var semanticError200: Color { get }
    var semanticError300: Color { get }
    var semanticError400: Color { get }
    var semanticError500: Color { get }
    var semanticError600: Color { get }
    var semanticError700: Color { get }
    var semanticError800: Color { get }
    var transparent: Color { get }
}

// MARK: - DefaultColorProvider

public struct DefaultColorProvider: ColorProviderProtocol {
    public init() {}

    public var neutrals0: Color { Primitives.Colours.neutrals0 }
    public var neutrals100: Color { Primitives.Colours.neutrals100 }
    public var neutrals200: Color { Primitives.Colours.neutrals200 }
    public var neutrals300: Color { Primitives.Colours.neutrals300 }
    public var neutrals400: Color { Primitives.Colours.neutrals400 }
    public var neutrals500: Color { Primitives.Colours.neutrals500 }
    public var neutrals600: Color { Primitives.Colours.neutrals600 }
    public var neutrals700: Color { Primitives.Colours.neutrals700 }
    public var neutrals800: Color { Primitives.Colours.neutrals800 }
    public var neutrals900: Color { Primitives.Colours.neutrals900 }
    public var semanticSuccess100: Color { Primitives.Colours.semanticSuccess100 }
    public var semanticSuccess200: Color { Primitives.Colours.semanticSuccess200 }
    public var semanticSuccess300: Color { Primitives.Colours.semanticSuccess300 }
    public var semanticSuccess400: Color { Primitives.Colours.semanticSuccess400 }
    public var semanticSuccess500: Color { Primitives.Colours.semanticSuccess500 }
    public var semanticSuccess600: Color { Primitives.Colours.semanticSuccess600 }
    public var semanticSuccess700: Color { Primitives.Colours.semanticSuccess700 }
    public var semanticSuccess800: Color { Primitives.Colours.semanticSuccess800 }
    public var semanticError100: Color { Primitives.Colours.semanticError100 }
    public var semanticError200: Color { Primitives.Colours.semanticError200 }
    public var semanticError300: Color { Primitives.Colours.semanticError300 }
    public var semanticError400: Color { Primitives.Colours.semanticError400 }
    public var semanticError500: Color { Primitives.Colours.semanticError500 }
    public var semanticError600: Color { Primitives.Colours.semanticError600 }
    public var semanticError700: Color { Primitives.Colours.semanticError700 }
    public var semanticError800: Color { Primitives.Colours.semanticError800 }
    public var transparent: Color { Primitives.Colours.transparentTransparent }
}
