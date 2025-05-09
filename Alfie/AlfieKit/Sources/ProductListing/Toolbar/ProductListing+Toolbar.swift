import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        configuration: ProductListingScreenConfiguration2,
        showSearchButton: Bool,
        openSearchAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier2(
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
                        ToolbarItemProvider2.searchItem(size: .normal, openSearchAction: openSearchAction)
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
