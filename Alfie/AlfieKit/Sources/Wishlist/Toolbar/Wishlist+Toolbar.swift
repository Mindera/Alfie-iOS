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
            DefaultToolbarModifier2(
                hasDivider: hasDivider,
                leadingItems: {
                    if hasDivider {
                        EmptyView()
                    } else {
                        ThemedToolbarTitle(
                            style: .leftText(L10n.Wishlist.title),
                            accessibilityId: AccessibilityID.titleHeader
                        )
                    }
                },
                principalItems: {
                    if hasDivider {
                        ThemedToolbarTitle(
                            style: .text(L10n.Wishlist.title),
                            accessibilityId: AccessibilityID.titleHeader
                        )
                    } else {
                        Spacer()
                    }
                },
                trailingItems: {
                    if hasDivider {
                        EmptyView()
                    } else {
                        ToolbarItemProvider2.accountItem(size: .big) {
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
