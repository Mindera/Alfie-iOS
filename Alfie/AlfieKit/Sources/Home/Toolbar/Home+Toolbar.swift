import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView() -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: false,
                leadingItems: {},
                principalItems: {
                    ThemedToolbarTitle(style: .logo, accessibilityId: AccessibilityID.titleHeader)
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
