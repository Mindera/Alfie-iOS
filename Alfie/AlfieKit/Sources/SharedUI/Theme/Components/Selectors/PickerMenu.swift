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
            RoundedRectangle(cornerRadius: CornerRadius.soft)
                .stroke(Primitives.Colours.neutrals400, lineWidth: 1)
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
                            .tint(Primitives.Colours.neutrals800)
                    }
                    .padding(.horizontal, Spacing.space200)
                }
                .background(Primitives.Colours.neutrals0)
                .cornerRadius(CornerRadius.soft)
        }
    }
}

#Preview {
    PickerMenu(isModalPresented: .constant(false)) { Text("Selected Option") }
}
