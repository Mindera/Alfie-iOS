import SwiftUI

// MARK: - DesignSystemProtocol

/// Single entry point for every design-token category (colour, spacing, radius, typography).
/// Each category forwards to the generated tokens, vended as one unit so the whole theme can be
/// injected via `EnvironmentValues.theme`.
public protocol DesignSystemProtocol {
    var color: ColorProvider { get }
    var spacing: SpacingProvider { get }
    var radius: RadiusProvider { get }
    var font: TypographyProviderProtocol { get }

    func setupAppearance()
}

// MARK: - DesignSystem

public class DesignSystem: DesignSystemProtocol {
    public static var shared = DesignSystem()

    // Token-backed categories are fixed forwarders to the generated tokens (no variation, so
    // concrete). Only `font` is a swappable provider.
    public let color = ColorProvider()
    public let spacing = SpacingProvider()
    public let radius = RadiusProvider()
    public let font: TypographyProviderProtocol

    public init(font: TypographyProviderProtocol = TypographyProvider()) {
        self.font = font
        setupAppearance()
    }

    public func setupAppearance() {
        let attributesNormal: [NSAttributedString.Key: Any] = [
            .font: font.heading.small.uiFont,
            .foregroundColor: Primitives.Colours.neutrals900.ui,
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributesNormal, for: .normal)

        let attributesSelected: [NSAttributedString.Key: Any] = [
            .font: font.heading.small.uiFont,
            .foregroundColor: Primitives.Colours.neutrals600.ui,
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributesSelected, for: .highlighted)

        UIBarButtonItem.appearance().tintColor = Primitives.Colours.neutrals900.ui

        setNavigationBarAppearance()
        setTabBarAppearance()
    }

    private func setNavigationBarAppearance() {
        let backgroundColor = Primitives.Colours.neutrals0.ui
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor

        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        backButtonAppearance.focused.titlePositionAdjustment = .init(horizontal: -44, vertical: 0)
        backButtonAppearance.disabled.titlePositionAdjustment = .init(horizontal: -44, vertical: 0)
        backButtonAppearance.highlighted.titlePositionAdjustment = .init(horizontal: -44, vertical: 0)
        backButtonAppearance.normal.titlePositionAdjustment = .init(horizontal: -44, vertical: 0)

        appearance.backButtonAppearance = backButtonAppearance
        appearance.setBackIndicatorImage(
            Icon.arrowLeft.uiImage,
            transitionMaskImage: Icon.arrowLeft.uiImage
        )

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func setTabBarAppearance() {
        let backgroundColor = Primitives.Colours.neutrals0.ui
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = backgroundColor
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// MARK: - Environment injection seam

// Injectable theme: the default is `DesignSystem.shared`; `.environment(\.theme, custom)` overrides
// it for a subtree (e.g. a brand theme, or a mock in previews/tests).
//
// IMPORTANT: a view only receives the injected theme if it reads `@Environment(\.theme)`. The
// `View.theme` / `ViewModifier.theme` convenience (Helpers/Extensions) always returns
// `DesignSystem.shared` and shadows this value, so the ~all-current `theme.*` call sites ignore any
// injection. Adopting injection in a view is therefore an explicit, per-view change — not automatic.
private struct DesignSystemKey: EnvironmentKey {
    static let defaultValue: DesignSystemProtocol = DesignSystem.shared
}

public extension EnvironmentValues {
    var theme: DesignSystemProtocol {
        get { self[DesignSystemKey.self] }
        set { self[DesignSystemKey.self] = newValue }
    }
}
