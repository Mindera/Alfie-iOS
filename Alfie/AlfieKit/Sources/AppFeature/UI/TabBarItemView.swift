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
        VStack(spacing: Primitives.Spacing.spacing8) {
            if tab == currentTab {
                Primitives.Colours.neutrals800
                    .frame(height: Constants.lineHeight)
                    .offset(y: Constants.offsetLineSelected)
                    .matchedGeometryEffect(id: Constants.effectID, in: namespace)
            } else {
                Primitives.Colours.transparentTransparent.frame(height: Constants.lineHeight)
            }
            tab.icon.image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(size: Constants.iconSize)
                .foregroundStyle(tab == currentTab ? Primitives.Colours.neutrals900 : Primitives.Colours.neutrals400)
                .badgeView(badgeValue: $badgeValue)
            if tab == currentTab {
                Text.build(theme.font.body.small(tab.title))
                    .foregroundStyle(Primitives.Colours.neutrals800)
            } else {
                Text.build(theme.font.body.small(tab.title))
                    .foregroundStyle(Primitives.Colours.neutrals500)
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
        static let iconSize: CGSize = .init(width: Sizing.iconsIconMedium, height: Sizing.iconsIconMedium)
    }
}
