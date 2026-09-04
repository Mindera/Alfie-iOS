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
        return VStack(spacing: Primitives.Spacing.spacing8) {
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
        .padding(.vertical, Primitives.Spacing.spacing8)
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
        static func iconColour(isSelected: Bool) -> Color {
            isSelected ? Theme.contentContentPrimary : Theme.contentContentPrimaryDisabled
        }

        static func labelColour(isSelected: Bool) -> Color {
            isSelected ? Theme.contentContentPrimary : Theme.contentContentTerciary
        }

        static func labelStyle(isSelected: Bool) -> ThemedTypographyStyle {
            isSelected ? DesignSystem.shared.font.label.smallBold : DesignSystem.shared.font.label.small
        }
    }

    private enum Constants {
        static let iconSize: CGSize = .init(width: Sizing.iconsIconMedium, height: Sizing.iconsIconMedium)
    }
}
