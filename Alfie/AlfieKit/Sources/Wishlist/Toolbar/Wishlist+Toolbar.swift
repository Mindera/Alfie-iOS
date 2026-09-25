import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        hasDivider: Bool,
        myAccountAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: hasDivider,
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    ThemedToolbarTitle(
                        style: .text(L10n.Wishlist.title),
                        accessibilityId: AccessibilityID.titleHeader
                    )
                },
                trailingItems: {
                    if hasDivider {
                        EmptyView()
                    } else {
                        ToolbarItemProvider.accountItem(size: .big) {
                            myAccountAction()
                        }
                    }
                }
            )
        )
    }
}

// MARK: - AccessibilityId

private enum AccessibilityID {
    static let accountBtn = "account-btn"
    static let titleHeader = "title-header"
}
