import AccessibilityIdentifiers
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
                    ThemedToolbarTitle(style: .logo, accessibilityId: AccessibilityID.Home.titleHeader)
                },
                trailingItems: {}
            )
        )
    }
}
