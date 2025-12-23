import Model
import SharedUI
import SwiftUI

struct CustomTabBarView: View {
    private let tabs: [Model.Tab]
    @Binding private var currentTab: Model.Tab
    @Namespace private var namespace
    @State private var badgeNumbers: [Model.Tab: Int?] = [:]
    private let popToRootAction: (Model.Tab) -> Void

    init(
        tabs: [Model.Tab],
        currentTab: Binding<Model.Tab>,
        popToRootAction: @escaping (Model.Tab) -> Void
    ) {
        self.tabs = tabs
        _currentTab = currentTab
        self.popToRootAction = popToRootAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space0) {
            Divider()
            HStack(spacing: Spacing.space0) {
                ForEach(tabs, id: \.self) { tab in
                    TabBarItemView(
                        tab: tab,
                        currentTab: $currentTab,
                        badgeValue: .init(get: { badgeValueFor(tab) }, set: { _ in }),
                        namespace: namespace.self,
                        popToRootAction: popToRootAction
                    )
                    .simultaneousGesture(TapGesture().onEnded { _ in badgeNumbers[tab] = nil })
                }
            }
        }
        .background(Colors.primary.white)
        .frame(width: UIScreen.main.bounds.width)
    }

    private func badgeValueFor(_ tab: Model.Tab) -> Int? {
        guard let value = badgeNumbers[tab] else {
            return nil
        }
        return value
    }
}
