import SwiftUI

// MARK: - BadgeViewModifier

/// Adds a badge to any view, controlled by an `Int` binding.
/// To clear the badge, set the value to `nil` or `0` (if `hideOnZero` is `true`)
/// To show an indicator, set the value to `0` and `hideOnZero` to `false`
/// If the value is set to higher than `maxValue`, the badge will show `maxValue+`
public struct BadgeViewModifier: ViewModifier {
    private enum Constants {
        static let badgeHeight = Primitives.Spacing.spacing16
        static let textPadding = Primitives.Spacing.spacing4
        static let indicatorHeight = Primitives.Spacing.spacing12
        static let indicatorWidth = Primitives.Spacing.spacing12
        static let capsuleOffsetXFactor = 3 // layout multiplier, no design token
        static let borderLineWidth = CGFloat(Primitives.Border.borderWeightDefault)
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
                        let badgeLabelsOffsetX = CGFloat(helper.badgeLabel.count * Constants.capsuleOffsetXFactor)
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: Sizing.radiusRounded)
                                .fill(Theme.surfaceBackgroundDestructive)
                                .frame(height: Constants.badgeHeight)
                            RoundedRectangle(cornerRadius: Sizing.radiusRounded)
                                .stroke(Theme.surfaceBackgroundPrimary, lineWidth: Constants.borderLineWidth)
                                .frame(height: Constants.badgeHeight)
                            Text.build(theme.font.body.small(helper.badgeLabel))
                                .foregroundStyle(Theme.contentContentInvertedPrimary)
                                .padding(.all, Constants.textPadding)
                        }
                        .frame(height: Constants.badgeHeight)
                        .frame(minWidth: Constants.badgeHeight)
                        .fixedSize(horizontal: true, vertical: false)
                        .offset(x: (Constants.badgeHeight / 2) + badgeLabelsOffsetX, y: -((Constants.badgeHeight / 2)))
                    } else {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Theme.surfaceBackgroundDestructive)
                                .frame(width: Constants.indicatorWidth, height: Constants.indicatorHeight)
                            RoundedRectangle(cornerRadius: Sizing.radiusRounded)
                                .stroke(Theme.surfaceBackgroundPrimary, lineWidth: Constants.borderLineWidth)
                                .frame(width: Constants.indicatorWidth, height: Constants.indicatorHeight)
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
