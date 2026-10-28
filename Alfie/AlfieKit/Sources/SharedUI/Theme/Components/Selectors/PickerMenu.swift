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
            RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
                .stroke(theme.color.borderStrong, lineWidth: 1)
                .frame(minHeight: Constants.frameMinHeight)
                .overlay {
                    HStack {
                        selectedOptionView
                        Spacer()
                        ThemedIcon(.chevronDown, size: .small, tint: theme.color.contentContentPrimary)
                    }
                    .padding(.horizontal, theme.sizing.spacingSpacingMd)
                }
                .background(theme.color.surfaceBackgroundPrimary)
                .cornerRadius(theme.sizing.radiusSoft)
        }
    }
}

#Preview {
    PickerMenu(isModalPresented: .constant(false)) { Text("Selected Option") }
}
