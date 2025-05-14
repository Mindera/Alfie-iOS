import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        username: String?,
        memberSince: Int?,
        openDebugAction: @escaping () -> Void,
        openMyAccountAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: false,
                leadingItems: {
                    if let username, let memberSince {
                        ThemedToolbarTitle(
                            style: .leftText(
                                L10n.Home.LoggedIn.title(username),
                                subtitle: L10n.Home.LoggedIn.subtitle("\(memberSince)")
                            ),
                            accessibilityId: AccessibilityID.titleHeader
                        )
                    } else {
                        ThemedToolbarTitle(style: .logo, accessibilityId: AccessibilityID.titleHeader)
                    }
                },
                principalItems: {
                    Spacer()
                },
                trailingItems: {
                    // TODO: Remove debug menu for production releases
                    ToolbarItemProvider.debugMenuItem(size: .big) {
                        openDebugAction()
                    }

                    ThemedToolbarButton(
                        icon: .user,
                        accessibilityId: AccessibilityID.accountBtn,
                        toolBarButtonSize: .big
                    ) {
                        openMyAccountAction()
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
