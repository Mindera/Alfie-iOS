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
        VStack {
            if showDivider {
                Divider()
                    .background(Primitives.Colours.neutrals200)
            }
            content
                .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
