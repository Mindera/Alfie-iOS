import SwiftUI

private enum Constants {
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
            RoundedRectangle(cornerRadius: Sizing.radiusSoft)
                .stroke(Primitives.Colours.neutrals400, lineWidth: 1)
                .frame(minHeight: Constants.frameMinHeight)
                .overlay {
                    HStack {
                        selectedOptionView
                        Spacer()
                        ThemedIcon(.chevronDown, size: .small, tint: Primitives.Colours.neutrals800)
                    }
                    .padding(.horizontal, Primitives.Spacing.spacing16)
                }
                .background(Primitives.Colours.neutrals0)
                .cornerRadius(Sizing.radiusSoft)
        }
    }
}

#Preview {
    PickerMenu(isModalPresented: .constant(false)) { Text("Selected Option") }
}
