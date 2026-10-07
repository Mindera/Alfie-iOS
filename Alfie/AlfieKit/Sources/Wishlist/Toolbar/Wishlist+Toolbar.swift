import AccessibilityIdentifiers
import Foundation
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(hasDivider: Bool) -> some View {
        self.modifier(
            DefaultToolbarModifier(
                hasDivider: hasDivider,
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    ThemedToolbarTitle(
                        style: .text(L10n.Wishlist.title),
                        accessibilityId: AccessibilityID.Wishlist.titleHeader
                    )
                },
                trailingItems: {
                    EmptyView()
                }
            )
        )
    }
}
