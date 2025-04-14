import Navigation
import SharedUI
import SwiftUI

extension View {
    func withToolbar(for screen: Screen) -> some View {
        modifier(DefaultToolbarModifier(screen: screen))
    }
}

// MARK: - DefaultToolbarModifier

struct DefaultToolbarModifier: ViewModifier {
    @EnvironmentObject var coordinator: Coordinator
    private let screen: Screen

    public init(screen: Screen) {
        self.screen = screen
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemProvider.leadingItems(for: screen, coordinator: coordinator)
                ToolbarItemProvider.principalItems(for: screen, coordinator: coordinator)
                ToolbarItemProvider.trailingItems(
                    for: screen,
                    coordinator: coordinator,
                    isWishlistEnabled: coordinator.isWishlistEnabled
                )
            }
            .modifier(ThemedToolbarModifier(showDivider: hasDivider))
    }

    private var hasDivider: Bool {
        // swiftlint:disable vertical_whitespace_between_cases
        switch screen {
        case .tab(.shop),
             .tab(.wishlist), // swiftlint:disable:this indentation_width
             .tab(.bag),
             .tab(.home):
            false
        default:
            true
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
