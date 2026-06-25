import Foundation

// MARK: - CornerRadius

// Corner radii are sourced from the design system's radius tokens: two finite radii —
// `radiusSoft` (4) and `radiusStrong` (16) — plus the `radiusRounded` (1000) pill.
// "No radius" is expressed by simply not applying a corner radius, so there is no `none` case.
public enum CornerRadius {
    /// 4pt — radius-soft
    public static let soft: CGFloat = Sizing.radiusSoft
    /// 16pt — radius-strong
    public static let strong: CGFloat = Sizing.radiusStrong
    /// 1000pt — radius-rounded (pill); pending design confirmation
    public static let rounded: CGFloat = Sizing.radiusRounded
}
