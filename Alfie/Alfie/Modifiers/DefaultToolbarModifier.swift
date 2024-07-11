import Navigation
import StyleGuide
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
                ToolbarItemProvider.trailingItems(for: screen,
                                                  coordinator: coordinator,
                                                  isPresentingDebugMenu: $coordinator.isPresentingDebugMenu)
            }
            .modifier(ThemedToolbarModifier(showDivider: hasDivider))
    }

    private var hasDivider: Bool {
        switch screen {
            case .tab(.shop), .tab(.wishlist), .tab(.bag), .tab(.home):
                false
            default:
                true
        }
    }
}
