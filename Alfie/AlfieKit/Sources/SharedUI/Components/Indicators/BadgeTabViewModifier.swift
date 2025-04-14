import SwiftUI

// MARK: - BadgeTabViewModifier

/// Adds a badge to a tab item, controlled by an Int binding
/// To clear the badge, set the value to `nil` or `0` (if `hideOnZero` is `true`)
/// To show an indicator, set the value to `0` and `hideOnZero` to `false`
/// If the value is set to higher than `maxValue`, the badge will show `maxValue+`
public struct BadgeTabViewModifier: ViewModifier {
    private var helper: BadgeHelper
    @Binding var badgeValue: Int?

    init(badgeValue: Binding<Int?>, hideOnZero: Bool = true) {
        _badgeValue = badgeValue
        helper = BadgeHelper(badgeValue: badgeValue, hideOnZero: hideOnZero)
        setAppearance()
    }

    private func setAppearance() {
        UITabBarItem.appearance().badgeColor = Colors.secondary.red700.ui

        let font = theme.font.tiny.normal
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: Colors.primary.white.ui,
        ]
        UITabBarItem.appearance().setBadgeTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes(attributes, for: .selected)
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if !helper.hideBadge {
            content
                .badge(helper.badgeLabel)
        } else {
            content
        }
    }
}

extension View {
    /// Helper extension to add a badge to a tab item on a tab view with support for indicator mode (i.e. show value `0` as a simple dot), controlled by an `Int` binding that can be set to `nil` to hide the badge.
    public func tabItemBadge(badgeValue: Binding<Int?>, hideOnZero: Bool = false) -> some View {
        modifier(BadgeTabViewModifier(badgeValue: badgeValue, hideOnZero: hideOnZero))
    }
}
