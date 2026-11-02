import SwiftUI

public struct ThemedToggleView<Content: View>: View {
    var label: () -> Content
    @Binding var isDisabled: Bool
    @Binding var isOn: Bool

    public init(isOn: Binding<Bool>, isDisabled: Binding<Bool> = .constant(false), label: @escaping () -> Content) {
        self.label = label
        _isDisabled = isDisabled
        _isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            label()
        }
        .tint(theme.color.surfaceBackgroundPositive)
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        ThemedToggleView(isOn: .constant(false)) { Text("This is a toggle") }

        ThemedToggleView(isOn: .constant(true)) {
            HStack {
                Text("This is a toggle")
                Icon.arrowLeft.image
            }
        }

        ThemedToggleView(isOn: .constant(false), isDisabled: .constant(true)) { Text("This is a toggle") }

        ThemedToggleView(isOn: .constant(true), isDisabled: .constant(true)) { Text("This is a toggle") }
    }
    .padding(.horizontal, 20)
}
