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
                .frame(width: theme.sizing.iconsIconMedium, height: theme.sizing.iconsIconMedium)
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

    enum Style: ThemeReading {
        static func iconColour(isSelected: Bool) -> Color {
            isSelected ? theme.color.contentContentPrimary : theme.color.contentContentPrimaryDisabled
        }

        static func labelColour(isSelected: Bool) -> Color {
            isSelected ? theme.color.contentContentPrimary : theme.color.contentContentTerciary
        }

        static func labelStyle(isSelected: Bool) -> ThemedTypographyStyle {
            isSelected ? theme.font.label.smallBold : theme.font.label.small
        }
    }
}
