import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        username: String?,
        memberSince: Int?
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: false,
                leadingItems: {
                    // Signed-in personalization stays leading; signed-out shows the centered logo (principal).
                    if let username, let memberSince {
                        ThemedToolbarTitle(
                            style: .leftText(
                                L10n.Home.LoggedIn.title(username),
                                subtitle: L10n.Home.LoggedIn.subtitle("\(memberSince)")
                            ),
                            accessibilityId: AccessibilityID.titleHeader
                        )
                    }
                },
                principalItems: {
                    if username == nil || memberSince == nil {
                        ThemedToolbarTitle(style: .logo, accessibilityId: AccessibilityID.titleHeader)
                    }
                },
                trailingItems: {}
            )
        )
    }
}

// MARK: - AccessibilityId

private enum AccessibilityID {
    static let titleHeader = "title-header"
}
