import SwiftUI

/// A non-editable search entry point: a VoiceOver-operable `Button` wrapping a display-only
/// `ThemedSearchBarView` (`.soft`). Tapping runs `action` — typically presenting the full search
/// flow. Shared by the Home and Shop headers so the button/accessibility wrapping lives in one place.
///
/// The inner bar is `.allowsHitTesting(false)` + `.accessibilityHidden(true)`, so the `Button` is the
/// single accessible element (its label/id come from the parameters). Callers own outer layout
/// (padding, `matchedGeometryEffect`, …).
public struct SearchBarEntryButton: View {
    private let placeholder: String
    private let accessibilityIdentifier: String
    private let action: () -> Void

    public init(
        placeholder: String,
        accessibilityIdentifier: String,
        action: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ThemedSearchBarView(
                searchText: .constant(""),
                placeholder: placeholder,
                theme: .soft,
                dismissConfiguration: .init(type: .hidden)
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(placeholder)
    }
}
