import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView() -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: false,
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    Text.build(theme.font.heading.xSmall(L10n.Bag.title))
                        .foregroundStyle(Theme.contentContentPrimary)
                        .accessibilityIdentifier(AccessibilityID.titleHeader)
                        .accessibilityAddTraits(.isHeader)
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
