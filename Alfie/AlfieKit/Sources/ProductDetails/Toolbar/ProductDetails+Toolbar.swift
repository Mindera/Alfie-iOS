import Foundation
import Model
import SharedUI
import SwiftUI

extension View {
    @ViewBuilder
    func toolbarView(
        productTitle: String,
        shareConfiguration: ShareConfiguration?,
        didFail: Bool
    ) -> some View {
        self.modifier(
            DefaultToolbarModifier2(
                hasDivider: true, // From VM?
                leadingItems: {
                    EmptyView()
                },
                principalItems: {
                    if !didFail {
                        ThemedToolbarTitle(style: .text(productTitle))
                    } else {
                        EmptyView()
                    }
                },
                trailingItems: {
                    if !didFail {
                        ToolbarItemProvider2.shareItem(configuration: shareConfiguration)
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
