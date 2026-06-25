import Foundation

// MARK: - CornerRadius

// Corner radii are sourced from the design system's radius tokens. The system defines exactly
// two finite radii — `radiusSoft` (4) and `radiusStrong` (16) — plus the `radiusRounded` (1000)
// pill. `none` is the absence of a radius (0, no token).

// swiftlint:disable discouraged_none_name
public enum CornerRadius {
    /// 0pt — absence of a radius (no radius token)
    public static let none: CGFloat = 0.0
    /// 4pt — radius-soft
    public static let soft: CGFloat = Sizing.radiusSoft
    /// 16pt — radius-strong
    public static let strong: CGFloat = Sizing.radiusStrong
    /// 1000pt — radius-rounded (pill); pending design confirmation
    public static let rounded: CGFloat = Sizing.radiusRounded
}
// swiftlint:enable discouraged_none_name
