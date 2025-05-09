import Model
import SharedUI
import SwiftUI

struct TabBarItemView: View {
    private let tab: Model.Tab
    @Binding private var currentTab: Model.Tab
    @Binding private var badgeValue: Int?
    private let namespace: Namespace.ID
    private let popToRootAction: (Model.Tab) -> Void

    init(
        tab: Model.Tab,
        currentTab: Binding<Model.Tab>,
        badgeValue: Binding<Int?>,
        namespace: Namespace.ID,
        popToRootAction: @escaping (Model.Tab) -> Void
    ) {
        self.tab = tab
        _currentTab = currentTab
        _badgeValue = badgeValue
        self.namespace = namespace
        self.popToRootAction = popToRootAction
    }

    var body: some View {
        VStack(spacing: Spacing.space100) {
            if tab == currentTab {
                Colors.primary.mono900
                    .frame(height: Constants.lineHeight)
                    .offset(y: Constants.offsetLineSelected)
                    .matchedGeometryEffect(id: Constants.effectID, in: namespace)
            } else {
                Color.clear.frame(height: Constants.lineHeight)
            }
            tab.icon.image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(size: Constants.iconSize)
                .foregroundStyle(tab == currentTab ? Colors.primary.black : Colors.primary.mono300)
                .badgeView(badgeValue: $badgeValue)
            if tab == currentTab {
                Text.build(theme.font.small.bold(tab.title))
                    .foregroundStyle(Colors.primary.mono900)
            } else {
                Text.build(theme.font.small.normal(tab.title))
                    .foregroundStyle(Colors.primary.mono500)
            }
        }
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

    private enum Constants {
        static let effectID: String = "underline"
        static let lineHeight: CGFloat = 2
        static let offsetLineSelected: CGFloat = -1
        static let iconSize: CGSize = .init(width: 24, height: 24)
    }
}
