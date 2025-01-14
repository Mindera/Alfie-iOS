import Foundation
import SwiftUI

/// Defines the default visuals of navigation bars according to the theme
public struct ThemedToolbarModifier: ViewModifier {
    private var showDivider: Bool

    public init(showDivider: Bool = true) {
        self.showDivider = showDivider
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Colors.primary.white)
            .toolbarBackground(showDivider ? .visible : .hidden, for: .navigationBar)
    }
}
