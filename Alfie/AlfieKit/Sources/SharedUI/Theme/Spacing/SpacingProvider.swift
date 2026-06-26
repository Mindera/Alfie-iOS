import CoreGraphics

/// Semantic spacing scale (base-unit multipliers), forwarded from the generated `Primitives.Spacing`
/// tokens. Vended through `DesignSystem`.
public struct SpacingProvider {
    public init() {}

    public var space0: CGFloat { Primitives.Spacing.spacing0 }
    public var space025: CGFloat { Primitives.Spacing.spacing2 }
    public var space050: CGFloat { Primitives.Spacing.spacing4 }
    /// 8pt — no `spacing-6` token; conformed to the nearest token.
    public var space075: CGFloat { Primitives.Spacing.spacing8 }
    public var space100: CGFloat { Primitives.Spacing.spacing8 }
    public var space150: CGFloat { Primitives.Spacing.spacing12 }
    public var space200: CGFloat { Primitives.Spacing.spacing16 }
    public var space250: CGFloat { Primitives.Spacing.spacing20 }
    public var space300: CGFloat { Primitives.Spacing.spacing24 }
    public var space400: CGFloat { Primitives.Spacing.spacing32 }
    public var space500: CGFloat { Primitives.Spacing.spacing40 }
    public var space600: CGFloat { Primitives.Spacing.spacing48 }
    public var space700: CGFloat { Primitives.Spacing.spacing56 }
    public var space800: CGFloat { Primitives.Spacing.spacing64 }
    public var space1000: CGFloat { Primitives.Spacing.spacing80 }
}
