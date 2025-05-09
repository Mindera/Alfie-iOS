import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        username: String?,
        memberSince: Int?,
        myAccountAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier2(
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
                    ThemedToolbarButton(
                        icon: .user,
                        accessibilityId: AccessibilityID.accountBtn,
                        toolBarButtonSize: .big
                    ) {
                        myAccountAction()
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
