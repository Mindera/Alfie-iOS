import Model
import SharedUI
import SwiftUI

struct TabBarItemView: View {
    private let tab: Model.Tab
    @Binding private var currentTab: Model.Tab
    private let badgeValue: Int?
    private let popToRootAction: (Model.Tab) -> Void

    init(
        tab: Model.Tab,
        currentTab: Binding<Model.Tab>,
        badgeValue: Int?,
        popToRootAction: @escaping (Model.Tab) -> Void
    ) {
        self.tab = tab
        _currentTab = currentTab
        self.badgeValue = badgeValue
        self.popToRootAction = popToRootAction
    }

    var body: some View {
        let isSelected = tab == currentTab
        return VStack(spacing: theme.sizing.spacingSpacingXs) {
            tab.icon(isSelected: isSelected).image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(size: Constants.iconSize)
                .foregroundStyle(Style.iconColour(isSelected: isSelected))
                .badgeView(badgeValue: .constant(badgeValue))
            Text.build(Style.labelStyle(isSelected: isSelected)(tab.title))
                .foregroundStyle(Style.labelColour(isSelected: isSelected))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.sizing.spacingSpacingXs)
        .contentShape(Rectangle())
        .accessibilityElement()
        .accessibilityIdentifier(tab.accessibilityId)
        .accessibilityLabel(tab.title)
        .accessibilityValue(badgeAccessibilityValue)
        .onTapGesture {
            if currentTab != tab {
                currentTab = tab
            } else {
                popToRootAction(tab)
            }
        }
        .animation(.emphasizedDecelerate, value: currentTab)
    }

    /// The badge is drawn inside an element that ignores its children, so its `Text` is invisible
    /// to VoiceOver and unreachable to XCUITest. Carrying the count as the element's value puts it
    /// back within reach of both without splitting the tab into several elements.
    private var badgeAccessibilityValue: String {
        badgeValue.map(L10n.Accessibility.bagBadge) ?? ""
    }

    enum Style {
        private static var color: Theme.Type { DesignSystem.shared.color }

        static func iconColour(isSelected: Bool) -> Color {
            isSelected ? color.contentContentPrimary : color.contentContentPrimaryDisabled
        }

        static func labelColour(isSelected: Bool) -> Color {
            isSelected ? color.contentContentPrimary : color.contentContentTerciary
        }

        static func labelStyle(isSelected: Bool) -> ThemedTypographyStyle {
            isSelected ? DesignSystem.shared.font.label.smallBold : DesignSystem.shared.font.label.small
        }
    }

    private enum Constants {
        static let iconSize: CGSize = .init(
            width: DesignSystem.shared.sizing.iconsIconMedium,
            height: DesignSystem.shared.sizing.iconsIconMedium
        )
    }
}
