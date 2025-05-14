import SwiftUI

public struct DefaultToolbarModifier<Leading: View, Principal: View, Trailing: View>: ViewModifier {
    private let hasDivider: Bool
    private let leadingItems: () -> Leading
    private let principalItems: () -> Principal
    private let trailingItems: () -> Trailing

    public init(
        hasDivider: Bool,
        @ViewBuilder leadingItems: @escaping () -> Leading,
        @ViewBuilder principalItems: @escaping () -> Principal,
        @ViewBuilder trailingItems: @escaping () -> Trailing
    ) {
        self.hasDivider = hasDivider
        self.leadingItems = leadingItems
        self.principalItems = principalItems
        self.trailingItems = trailingItems
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    leadingItems()
                }
                ToolbarItem(placement: .principal) {
                    principalItems()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    trailingItems()
                }
            }
            .modifier(ThemedToolbarModifier(showDivider: hasDivider))
    }
}
