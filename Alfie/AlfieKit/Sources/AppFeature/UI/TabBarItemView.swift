import Model
import SharedUI
import SwiftUI

struct TabBarItemView: View {
    private let tab: Model.Tab
    @Binding private var currentTab: Model.Tab
    @Binding private var badgeValue: Int?
    private let popToRootAction: (Model.Tab) -> Void

    init(
        tab: Model.Tab,
        currentTab: Binding<Model.Tab>,
        badgeValue: Binding<Int?>,
        popToRootAction: @escaping (Model.Tab) -> Void
    ) {
        self.tab = tab
        _currentTab = currentTab
        _badgeValue = badgeValue
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
                .badgeView(badgeValue: $badgeValue)
            Text.build(isSelected ? theme.font.label.smallBold(tab.title) : theme.font.label.small(tab.title))
                .foregroundStyle(Style.labelColour(isSelected: isSelected))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Primitives.Spacing.spacing8)
        .contentShape(Rectangle())
        .accessibilityElement()
        .accessibilityIdentifier(tab.accessibilityId)
        .onTapGesture {
            if currentTab != tab {
                currentTab = tab
            } else {
                popToRootAction(tab)
            }
        }
        .animation(.emphasizedDecelerate, value: currentTab)
    }

    enum Style {
        static func iconColour(isSelected: Bool) -> Color {
            isSelected ? Theme.contentContentPrimary : Theme.contentContentPrimaryDisabled
        }

        static func labelColour(isSelected: Bool) -> Color {
            isSelected ? Theme.contentContentPrimary : Theme.contentContentTerciary
        }
    }

    private enum Constants {
        static let iconSize: CGSize = .init(width: Sizing.iconsIconMedium, height: Sizing.iconsIconMedium)
    }
}
