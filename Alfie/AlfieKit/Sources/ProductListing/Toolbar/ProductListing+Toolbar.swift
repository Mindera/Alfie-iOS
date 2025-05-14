import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        configuration: ProductListingScreenConfiguration,
        showSearchButton: Bool,
        openSearchAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: true,
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    ThemedToolbarTitle(
                        style: .text(configuration.category.orEmpty),
                        accessibilityId: AccessibilityID.titleHeader
                    )
                },
                trailingItems: {
                    if showSearchButton {
                        ToolbarItemProvider.searchItem(size: .normal, openSearchAction: openSearchAction)
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
