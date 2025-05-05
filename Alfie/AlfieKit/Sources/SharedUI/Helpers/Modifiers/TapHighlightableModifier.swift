import SwiftUI

/// Modifies any view so it can be tapped and show an highlight in that case, with an action closure, to simulate the behaviour of table view rows
public struct TapHighlightableModifier: ViewModifier {
    private var action: () -> Void
    private var accessibilityId: String

    public init(action: @escaping () -> Void, accessibilityId: String = "") {
        self.action = action
        self.accessibilityId = accessibilityId
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        Button(action: {
            action()
        }, label: {
            content
                .contentShape(Rectangle())
        })
        .buttonStyle(HighlightButtonStyle())
        .listRowInsets(EdgeInsets())
        .accessibilityIdentifier(accessibilityId)
    }
}

private struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Colors.primary.mono100 : .clear)
    }
}
