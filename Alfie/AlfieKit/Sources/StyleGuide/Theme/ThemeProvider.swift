import SwiftUI

// MARK: - ThemeProviderProtocol

public protocol ThemeProviderProtocol {
    var font: TypographyProviderProtocol { get }
    var shape: ShapeProviderProtocol { get }

    func setupAppearance()
}

// MARK: - ThemeProvider

public class ThemeProvider: ThemeProviderProtocol {
    public static var shared = ThemeProvider()

    public var font: TypographyProviderProtocol
    public var shape: ShapeProviderProtocol = DefaultShapeProvider()

    public init(font: TypographyProviderProtocol = TypographyProvider()) {
        self.font = font
        setupAppearance()
    }

    public func setupAppearance() {
        let attributesNormal: [NSAttributedString.Key: Any] = [
            .font: font.header.h3,
            .foregroundColor: Colors.primary.black.ui,
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributesNormal, for: .normal)

        let attributesSelected: [NSAttributedString.Key: Any] = [
            .font: font.header.h3,
            .foregroundColor: Colors.primary.mono700.ui,
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributesSelected, for: .highlighted)

        UIBarButtonItem.appearance().tintColor = Colors.primary.black.ui

        setNavigationBarAppearance()
        setTabBarAppearance()
    }

    private func setNavigationBarAppearance() {
        let backgroundColor = Colors.primary.white.ui
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func setTabBarAppearance() {
        let backgroundColor = Colors.primary.white.ui
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = backgroundColor
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
