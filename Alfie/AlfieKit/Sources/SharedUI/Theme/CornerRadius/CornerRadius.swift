import Foundation

// swiftlint:disable discouraged_none_name identifier_name

// MARK: - CornerRadius

// Corner radii are sourced from the design system's radius tokens. The system defines only
// `radiusSoft` (4) and `radiusStrong` (16) for finite radii, so each case maps by size:
// < 10pt → radiusSoft, ≥ 10pt → radiusStrong. `none` has no radius token (it is the absence of
// a radius). `full` (pill) stays on `radiusRounded` pending design confirmation.
public enum CornerRadius {
    /// 0pt — no radius token (absence of a radius)
    public static let none: CGFloat = 0.0
    /// 4pt (radius-soft)
    public static let xxs: CGFloat = Sizing.radiusSoft
    /// 4pt (radius-soft)
    public static let xs: CGFloat = Sizing.radiusSoft
    /// 4pt (radius-soft)
    public static let s: CGFloat = Sizing.radiusSoft
    /// 16pt (radius-strong)
    public static let m: CGFloat = Sizing.radiusStrong
    /// 16pt (radius-strong)
    public static let l: CGFloat = Sizing.radiusStrong
    /// 16pt (radius-strong)
    public static let xl: CGFloat = Sizing.radiusStrong
    /// 1000pt (radius-rounded) — pending design confirmation
    public static let full: CGFloat = Sizing.radiusRounded
}

// swiftlint:enable discouraged_none_name identifier_name
