import CoreGraphics

/// Component sizes with no design token yet (#235). Each is held on its primitive until design ships
/// the token; then swap the primitive here for the generated `Sizing` token.
public enum ComponentSize {
    public static let buttonHeightSmall: CGFloat = Primitives.Spacing.spacing32
    public static let buttonHeightMedium: CGFloat = Primitives.Spacing.spacing40
    public static let buttonHeightLarge: CGFloat = Primitives.Spacing.spacing48
    public static let tapTargetMinimum: CGFloat = Primitives.Spacing.spacing44
    public static let tapTargetCompact: CGFloat = Primitives.Spacing.spacing32
    public static let badgeHeight: CGFloat = Primitives.Spacing.spacing16
    public static let badgeIndicator: CGFloat = Primitives.Spacing.spacing12
    public static let chipCloseIcon: CGFloat = Primitives.Spacing.spacing12
    public static let stepperHeight: CGFloat = Primitives.Spacing.spacing40
    public static let spinnerLarge: CGFloat = Primitives.Spacing.spacing48
}
