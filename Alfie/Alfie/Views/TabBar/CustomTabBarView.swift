import StyleGuide
import SwiftUI

// MARK: - CustomTabBarView

struct CustomTabBarView: View {
    private let tabs: [TabScreen]
    @Binding private var currentTab: TabScreen
    @Namespace private var namespace
    @State private var badgeNumbers: [TabScreen: Int?] = [:]

    init(tabs: [TabScreen], currentTab: Binding<TabScreen>) {
        self.tabs = tabs
        _currentTab = currentTab
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space0) {
            Divider()
            HStack(spacing: Spacing.space0) {
                ForEach(tabs, id: \.id) { tab in
                    TabBarItemView(
                        tab: tab,
                        currentTab: $currentTab,
                        badgeValue: .init(get: { badgeValueFor(tab) }, set: { _ in }),
                        namespace: namespace.self
                    )
                    .simultaneousGesture(TapGesture().onEnded { _ in badgeNumbers[tab] = nil })
                }
            }
        }
        .background(Colors.primary.white)
        .frame(width: UIScreen.main.bounds.width)
    }

    private func badgeValueFor(_ tab: TabScreen) -> Int? {
        guard let value = badgeNumbers[tab] else {
            return nil
        }
        return value
    }
}

// MARK: - TabBarItemView

struct TabBarItemView: View {
    @EnvironmentObject private var tabCoordinator: TabCoordinator
    private let tab: TabScreen
    @Binding private var currentTab: TabScreen
    @Binding private var badgeValue: Int?
    private let namespace: Namespace.ID

    init(tab: TabScreen, currentTab: Binding<TabScreen>, badgeValue: Binding<Int?>, namespace: Namespace.ID) {
        self.tab = tab
        _currentTab = currentTab
        _badgeValue = badgeValue
        self.namespace = namespace
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
                tabCoordinator.popToRoot()
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
