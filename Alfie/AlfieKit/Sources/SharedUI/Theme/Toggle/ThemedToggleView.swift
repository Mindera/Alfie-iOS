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

private enum ColorToggle: ThemeReading {
    static var toggleCircle: Color { theme.color.contentContentSecondary }
    static var toggleCircleDisabled: Color { theme.color.contentContentPrimaryDisabled }
    // swiftlint:disable:next no_primitive_tokens - design review #186: no toggle on token
    static let toggleBorderOn = Primitives.Colours.semanticSuccess700
    static var toggleBorderOff: Color { theme.color.borderMedium }
    // swiftlint:disable:next no_primitive_tokens - design review #186: no toggle on token
    static let toggleBorderOnDisabled = Primitives.Colours.semanticSuccess200
    static var toggleBorderOffDisabled: Color { theme.color.surfaceForegroundPrimary }
    // swiftlint:disable:next no_primitive_tokens - design review #186: no toggle on token
    static let toggleBackgroundOn = Primitives.Colours.semanticSuccess100
    static var toggleBackgroundOff: Color { theme.color.surfaceBackgroundTerciary }
    static var toggleBackgroundOnDisabled: Color { theme.color.surfaceBackgroundPrimary }
    static var toggleBackgroundOffDisabled: Color { theme.color.surfaceForegroundPrimary }
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
