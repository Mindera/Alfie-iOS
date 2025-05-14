import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func subCategoriesToolbarView(title: String) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: true,
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
