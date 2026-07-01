import SwiftUI

// MARK: - ThemedToggleView

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
        .disabled(isDisabled)
        .toggleStyle(ThemedToggleStyle(isDisable: isDisabled))
    }
}

// MARK: - ThemedToggleStyle

struct ThemedToggleStyle: ToggleStyle {
    var isDisable: Bool

    private enum Constants {
        static var widthComponent: CGFloat = 56
        static var heightComponent: CGFloat = 32
        static var widthInnerComponent: CGFloat = 54
        static var heightInnerComponent: CGFloat = 30
        static var movementToggle: CGFloat = 12
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            RoundedRectangle(cornerRadius: Constants.heightInnerComponent)
                .fill(borderColor(configuration))
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.heightInnerComponent)
                            .fill(backgroundColor(configuration))
                            .frame(width: Constants.widthInnerComponent, height: Constants.heightInnerComponent)
                        Circle()
                            .fill(circleColor(configuration))
                            .padding(3)
                            .offset(x: configuration.isOn ? Constants.movementToggle : (-1 * Constants.movementToggle))
                    }
                }
                .frame(width: Constants.widthComponent, height: Constants.heightComponent)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }

    private func borderColor(_ configuration: Configuration) -> Color {
        configuration.isOn
            ? (isDisable ? ColorToggle.toggleBorderOnDisabled : ColorToggle.toggleBorderOn)
            : (isDisable ? ColorToggle.toggleBorderOffDisabled : ColorToggle.toggleBorderOff)
    }

    private func backgroundColor(_ configuration: Configuration) -> Color {
        configuration.isOn
            ? (isDisable ? ColorToggle.toggleBackgroundOnDisabled : ColorToggle.toggleBackgroundOn)
            : (isDisable ? ColorToggle.toggleBackgroundOffDisabled : ColorToggle.toggleBackgroundOff)
    }

    private func circleColor(_: Configuration) -> Color {
        isDisable ? ColorToggle.toggleCircleDisabled : ColorToggle.toggleCircle
    }
}

// MARK: - ColorToggle

private enum ColorToggle {
    // Computed so a runtime theme switch (+ soft-reboot) is reflected — a `static let` would cache
    // the launch theme's colour for the process lifetime.
    static var toggleCircle: Color { Primitives.Colours.neutrals600 }
    static var toggleCircleDisabled: Color { Primitives.Colours.neutrals300 }
    static var toggleBorderOn: Color { Primitives.Colours.semanticSuccess700 }
    static var toggleBorderOff: Color { Primitives.Colours.neutrals300 }
    static var toggleBorderOnDisabled: Color { Primitives.Colours.semanticSuccess200 }
    static var toggleBorderOffDisabled: Color { Primitives.Colours.neutrals100 }
    static var toggleBackgroundOn: Color { Primitives.Colours.semanticSuccess100 }
    static var toggleBackgroundOff: Color { Primitives.Colours.neutrals300 }
    static var toggleBackgroundOnDisabled: Color { Primitives.Colours.neutrals0 }
    static var toggleBackgroundOffDisabled: Color { Primitives.Colours.neutrals100 }
}

#Preview {
    @State var isOn = true
    return VStack {
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
