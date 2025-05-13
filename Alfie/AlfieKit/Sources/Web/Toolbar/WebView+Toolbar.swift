import Foundation
import SharedUI
import SwiftUI

public extension View {
    @ViewBuilder
    func toolbarView(title: String) -> some View {
        self.modifier(
            DefaultToolbarModifier2(
                hasDivider: false,
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    ThemedToolbarTitle(style: .text(title), accessibilityId: AccessibilityID.titleHeader)
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
