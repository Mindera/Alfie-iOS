import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView() -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: true, // From VM?
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    ThemedToolbarTitle(
                        style: .text(L10n.Account.title),
                        accessibilityId: AccessibilityID.titleHeader
                    )
                },
                trailingItems: {
                    EmptyView()
                }
            )
        )
    }
}

// MARK: - AccessibilityId

private enum AccessibilityID {
    static let titleHeader = "title-header"
}
