import SwiftUI

// MARK: - ThemedToggleView

struct ThemedToggleView<Content: View>: View {
    var label: () -> Content
    @Binding var isDisabled: Bool
    @Binding var isOn: Bool

    init(isOn: Binding<Bool>, isDisabled: Binding<Bool> = .constant(false), label: @escaping () -> Content) {
        self.label = label
        _isDisabled = isDisabled
        _isOn = isOn
    }

    var body: some View {
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
        configuration.isOn ? isDisable ? ColorToggle.toggleBorderOnDisabled : ColorToggle.toggleBorderOn : isDisable ? ColorToggle.toggleBorderOffDisabled : ColorToggle.toggleBorderOff
    }

    private func backgroundColor(_ configuration: Configuration) -> Color {
        configuration.isOn ? isDisable ? ColorToggle.toggleBackgroundOnDisabled : ColorToggle.toggleBackgroundOn : isDisable ? ColorToggle.toggleBackgroundOffDisabled : ColorToggle.toggleBackgroundOff
    }

    private func circleColor(_: Configuration) -> Color {
        isDisable ? ColorToggle.toggleCircleDisabled : ColorToggle.toggleCircle
    }
}

// MARK: - ColorToggle

private enum ColorToggle {
    static var toggleCircle = Color("toggleCircle", bundle: Bundle.module)
    static var toggleCircleDisabled = Color("toggleCircleDisabled", bundle: Bundle.module)
    static var toggleBorderOn = Color("toggleBorderOn", bundle: Bundle.module)
    static var toggleBorderOff = Color("toggleBorderOff", bundle: Bundle.module)
    static var toggleBorderOnDisabled = Color("toggleBorderOnDisabled", bundle: Bundle.module)
    static var toggleBorderOffDisabled = Color("toggleBorderOffDisabled", bundle: Bundle.module)
    static var toggleBackgroundOn = Color("toggleBackgroundOn", bundle: Bundle.module)
    static var toggleBackgroundOff = Color("toggleBackgroundOff", bundle: Bundle.module)
    static var toggleBackgroundOnDisabled = Color("toggleBackgroundOnDisabled", bundle: Bundle.module)
    static var toggleBackgroundOffDisabled = Color("toggleBackgroundOffDisabled", bundle: Bundle.module)
}

#Preview {
    @State var isOn = true
    return VStack {
        ThemedToggleView(isOn: .constant(false), label: {
            Text("This is a toggle")
        })

        ThemedToggleView(isOn: .constant(true), label: {
            HStack {
                Text("This is a toggle")
                Icon.arrowLeft.image
            }
        })

        ThemedToggleView(isOn: .constant(false), isDisabled: .constant(true), label: {
            Text("This is a toggle")
        })

        ThemedToggleView(isOn: .constant(true), isDisabled: .constant(true), label: {
            Text("This is a toggle")
        })
    }.padding(.horizontal, 20)
}
