import CoreGraphics

// MARK: - RadiusProviderProtocol

/// Corner-radius tokens (`soft` 4, `strong` 16, `rounded` 1000 pill), forwarded from the generated
/// `Sizing` tokens. Vended through `DesignSystem` so radius is injectable as part of the theme.
public protocol RadiusProviderProtocol {
    var soft: CGFloat { get }
    var strong: CGFloat { get }
    var rounded: CGFloat { get }
}

// MARK: - DefaultRadiusProvider

public struct DefaultRadiusProvider: RadiusProviderProtocol {
    public init() {}

    public var soft: CGFloat { Sizing.radiusSoft }
    public var strong: CGFloat { Sizing.radiusStrong }
    // `radius-rounded` is 1000pt — a pill convention (an oversized radius that always fully rounds),
    // not a real corner-radius value. Kept as-is because it is what the generated design token
    // defines; pending design/team confirmation of the intended pill token.
    public var rounded: CGFloat { Sizing.radiusRounded }
}
