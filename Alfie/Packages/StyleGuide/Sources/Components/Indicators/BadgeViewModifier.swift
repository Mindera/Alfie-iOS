import SwiftUI

// MARK: - BadgeViewModifier

/// Adds a badge to any view, controlled by an `Int` binding.
/// To clear the badge, set the value to `nil` or `0` (if `hideOnZero` is `true`)
/// To show an indicator, set the value to `0` and `hideOnZero` to `false`
/// If the value is set to higher than `maxValue`, the badge will show `maxValue+`
public struct BadgeViewModifier: ViewModifier {
    private enum Constants {
        static let badgeHeight = 16.0
        static let badgePadding = 4.0
        static let textPadding = 4.0
        static let indicatorHeight = 12.0
        static let indicatorWidth = 12.0
        static let capsuleOffsetXFactor = 3
        static let borderLineWidth = 1.0
    }

    private var helper: BadgeHelper
    @Binding private var badgeValue: Int?

    init(badgeValue: Binding<Int?>, hideOnZero: Bool = true) {
        _badgeValue = badgeValue
        helper = BadgeHelper(badgeValue: badgeValue, hideOnZero: hideOnZero)
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if !helper.hideBadge {
            content
                .overlay(alignment: .topTrailing) {
                    if !helper.isIndicator {
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: CornerRadius.full)
                                .fill(Colors.secondary.red700)
                                .frame(height: Constants.badgeHeight)
                            RoundedRectangle(cornerRadius: CornerRadius.full)
                                .stroke(Colors.primary.white, lineWidth: Constants.borderLineWidth)
                                .frame(height: Constants.badgeHeight)
                            Text.build(theme.font.tiny.normal(helper.badgeLabel))
                                .foregroundColor(Colors.primary.white)
                                .padding(.all, Constants.textPadding)
                        }
                        .frame(height: Constants.badgeHeight)
                        .frame(minWidth: Constants.badgeHeight)
                        .fixedSize(horizontal: true, vertical: false)
                        .offset(x: (Constants.badgeHeight / 2) + CGFloat(helper.badgeLabel.count * Constants.capsuleOffsetXFactor), y: -((Constants.badgeHeight / 2)))
                    } else {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Colors.secondary.red700)
                                .frame(width: Constants.indicatorWidth,
                                       height: Constants.indicatorHeight)
                            RoundedRectangle(cornerRadius: CornerRadius.full)
                                .stroke(Colors.primary.white, lineWidth: Constants.borderLineWidth)
                                .frame(width: Constants.indicatorWidth,
                                       height: Constants.indicatorHeight)
                        }
                        .offset(x: (Constants.indicatorWidth / 2), y: -((Constants.indicatorHeight / 2)))
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    /// Helper extension to add a badge to a view with support for indicator mode (i.e. show value `0` as a simple dot), controlled by an `Int` binding that can be set to `nil` to hide the badge.
    public func badgeView(badgeValue: Binding<Int?>, hideOnZero: Bool = false) -> some View {
        modifier(BadgeViewModifier(badgeValue: badgeValue, hideOnZero: hideOnZero))
    }
}
