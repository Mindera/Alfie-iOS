import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        isRoot: Bool,
        isWishlistEnabled: Bool,
        openWishlistAction: @escaping () -> Void,
        myAccountAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: false,
                leadingItems: {
                    if isRoot {
                        ThemedToolbarTitle(
                            style: .leftText(L10n.Shop.title),
                            accessibilityId: AccessibilityID.titleHeader
                        )
                    } else {
                        EmptyView()
                    }
                },
                principalItems: {
                    if isRoot {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                },
                trailingItems: {
                    if isRoot {
                        if isWishlistEnabled {
                            ToolbarItemProvider.wishlistItem(size: .big) {
                                openWishlistAction()
                            }
                        }
                        ToolbarItemProvider.accountItem(size: .big) {
                            myAccountAction()
                        }
                    } else {
                        EmptyView()
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
