import SwiftUI

public struct ThemedBackButton: View {
    private let accessibilityIdentifier: String
    private let action: () -> Void

    public init(accessibilityIdentifier: String, action: @escaping () -> Void) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ThemedIcon(
                .chevronLeft,
                size: .medium,
                tint: Primitives.Colours.neutrals800,
                accessibilityLabel: L10n.Accessibility.back
            )
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
