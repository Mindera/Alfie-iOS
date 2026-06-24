import Foundation

// swiftlint:disable discouraged_none_name identifier_name

// MARK: - CornerRadius

public enum CornerRadius {
    /// 0pt
    public static let none: CGFloat = Primitives.Spacing.spacing0
    /// 2pt
    public static let xxs: CGFloat = Primitives.Spacing.spacing2
    /// 4pt
    public static let xs: CGFloat = Sizing.radiusSoft
    /// 8pt
    public static let s: CGFloat = Primitives.Spacing.spacing8
    /// 12pt
    public static let m: CGFloat = Primitives.Spacing.spacing12
    /// 16pt
    public static let l: CGFloat = Sizing.radiusStrong
    /// 24pt
    public static let xl: CGFloat = Primitives.Spacing.spacing24
    /// 1000pt
    public static let full: CGFloat = Sizing.radiusRounded
}

// swiftlint:enable discouraged_none_name identifier_name
