import Foundation
import SwiftUI

// MARK: - Spacing

public enum Spacing {
    /// 0pt
    public static let space0: CGFloat = Primitives.Spacing.spacing0
    /// 2pt
    public static let space025: CGFloat = Primitives.Spacing.spacing2
    /// 4pt
    public static let space050: CGFloat = Primitives.Spacing.spacing4
    /// 8pt — conformed from 6pt to the nearest design token (no spacing-6 primitive exists)
    public static let space075: CGFloat = Primitives.Spacing.spacing8
    /// 8pt
    public static let space100: CGFloat = Primitives.Spacing.spacing8
    /// 12pt
    public static let space150: CGFloat = Primitives.Spacing.spacing12
    /// 16pt
    public static let space200: CGFloat = Primitives.Spacing.spacing16
    /// 20pt
    public static let space250: CGFloat = Primitives.Spacing.spacing20
    /// 24pt
    public static let space300: CGFloat = Primitives.Spacing.spacing24
    /// 32pt
    public static let space400: CGFloat = Primitives.Spacing.spacing32
    /// 40pt
    public static let space500: CGFloat = Primitives.Spacing.spacing40
    /// 48pt
    public static let space600: CGFloat = Primitives.Spacing.spacing48
    /// 56pt
    public static let space700: CGFloat = Primitives.Spacing.spacing56
    /// 64pt
    public static let space800: CGFloat = Primitives.Spacing.spacing64
    /// 80pt
    public static let space1000: CGFloat = Primitives.Spacing.spacing80
}
