import SwiftUI

// MARK: - DesignSystemProtocol

/// Single entry point for every design-token category (colours, spacing, radius, typography,
/// shape). Each category is a protocol-backed provider forwarding to the generated tokens, so the
/// whole system can be swapped — and later injected via `EnvironmentValues.theme` — as one unit.
public protocol DesignSystemProtocol {
    var color: ColorProviderProtocol { get }
    var spacing: SpacingProviderProtocol { get }
    var radius: RadiusProviderProtocol { get }
    var font: TypographyProviderProtocol { get }

    func setupAppearance()
}

// MARK: - DesignSystem

public class DesignSystem: DesignSystemProtocol {
    public static var shared = DesignSystem()

    public var color: ColorProviderProtocol
    public var spacing: SpacingProviderProtocol
    public var radius: RadiusProviderProtocol
    public var font: TypographyProviderProtocol

    public init(
        color: ColorProviderProtocol = DefaultColorProvider(),
        spacing: SpacingProviderProtocol = DefaultSpacingProvider(),
        radius: RadiusProviderProtocol = DefaultRadiusProvider(),
        font: TypographyProviderProtocol = TypographyProvider()
    ) {
        self.color = color
        self.spacing = spacing
        self.radius = radius
        self.font = font
        setupAppearance()
    }

    public func setupAppearance() {
        let attributesNormal: [NSAttributedString.Key: Any] = [
            .font: font.header.h3,
            .foregroundColor: Primitives.Colours.neutrals900.ui,
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributesNormal, for: .normal)

        let attributesSelected: [NSAttributedString.Key: Any] = [
            .font: font.header.h3,
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

// Ready for `@Environment(\.theme)` injection. Unused for now — `DesignSystem.shared` remains the
// default — so views can opt in (and previews/tests can inject a mock) without any call-site churn.
private struct DesignSystemKey: EnvironmentKey {
    static let defaultValue: DesignSystemProtocol = DesignSystem.shared
}

public extension EnvironmentValues {
    var theme: DesignSystemProtocol {
        get { self[DesignSystemKey.self] }
        set { self[DesignSystemKey.self] = newValue }
    }
}
