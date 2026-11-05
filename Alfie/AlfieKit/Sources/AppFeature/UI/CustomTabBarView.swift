import Model
import SharedUI
import SwiftUI

struct CustomTabBarView: View {
    private let tabs: [Model.Tab]
    @Binding private var currentTab: Model.Tab
    private let bagBadgeValue: Int?
    private let popToRootAction: (Model.Tab) -> Void

    init(
        tabs: [Model.Tab],
        currentTab: Binding<Model.Tab>,
        bagBadgeValue: Int?,
        popToRootAction: @escaping (Model.Tab) -> Void
    ) {
        self.tabs = tabs
        _currentTab = currentTab
        self.bagBadgeValue = bagBadgeValue
        self.popToRootAction = popToRootAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingNone) {
            Divider()
                .overlay(theme.color.borderSoft)
            HStack(spacing: theme.sizing.spacingSpacingNone) {
                ForEach(tabs, id: \.self) { tab in
                    TabBarItemView(
                        tab: tab,
                        currentTab: $currentTab,
                        badgeValue: badgeValueFor(tab),
                        popToRootAction: popToRootAction
                    )
                }
            }
        }
        .background(theme.color.surfaceBackgroundPrimary)
        .frame(maxWidth: .infinity)
    }

    // The bag is the only tab carrying a badge today.
    private func badgeValueFor(_ tab: Model.Tab) -> Int? {
        tab == .bag ? bagBadgeValue : nil
    }
}
