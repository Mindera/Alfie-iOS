import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        isWishlistEnabled: Bool,
        openWishlistAction: @escaping () -> Void,
        myAccountAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier2(
                hasDivider: false,
                leadingItems: {
                    ThemedToolbarTitle(
                        style: .leftText(L10n.Bag.title),
                        accessibilityId: AccessibilityID.titleHeader
                    )
                },
                principalItems: {
                    Spacer()
                },
                trailingItems: {
                    if isWishlistEnabled {
                        ToolbarItemProvider2.wishlistItem(size: .big) {
                            openWishlistAction()
                        }
                    }
                    ToolbarItemProvider2.accountItem(size: .big) {
                        myAccountAction()
                    }
                }
            )
        )
    }
}

// MARK: - AccessibilityId

private enum AccessibilityID {
    static let titleHeader = "title-header"
}
