import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 16
    static let frameMinHeight: CGFloat = 44
}

public struct PickerMenu<Content: View>: View {
    @Binding private var isModalPresented: Bool
    private var selectedOptionView: Content

    public init(isModalPresented: Binding<Bool>, @ViewBuilder selectedOptionView: () -> Content) {
        self._isModalPresented = isModalPresented
        self.selectedOptionView = selectedOptionView()
    }

    public var body: some View {
        Button { isModalPresented = true } label: {
            RoundedRectangle(cornerRadius: CornerRadius.xs)
                .stroke(Colors.primary.mono300, lineWidth: 1)
                .frame(minHeight: Constants.frameMinHeight)
                .overlay {
                    HStack {
                        selectedOptionView
                        Spacer()
                        Icon.chevronDown.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .tint(Colors.primary.mono900)
                    }
                    .padding(.horizontal, Spacing.space200)
                }
                .background(Colors.primary.white)
                .cornerRadius(CornerRadius.xs)
        }
    }
}

#Preview {
    PickerMenu(isModalPresented: .constant(false)) { Text("Selected Option") }
}
