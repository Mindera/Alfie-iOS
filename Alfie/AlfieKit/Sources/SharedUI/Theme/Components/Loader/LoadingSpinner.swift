import SwiftUI

/// Design-system loading spinner: the Figma spinner artwork, rotated. Sizes S/M/L.
public struct LoadingSpinner: View {
    public enum Size {
        case small
        case medium
        case large
    }

    private enum Constants {
        static let rotationDuration: Double = 1
    }

    @Environment(\.theme) private var theme
    private let size: Size
    @State private var isRotating = false

    public init(size: Size = .small) {
        self.size = size
    }

    private var dimension: CGFloat {
        switch size {
        case .small: theme.spacing.space300
        case .medium: theme.spacing.space400
        case .large: theme.spacing.space600
        }
    }

    public var body: some View {
        Image(ThemedImage.loadingSpinner.literalName, bundle: ThemedImage.loadingSpinner.bundle)
            .resizable()
            .scaledToFit()
            .frame(width: dimension, height: dimension)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: Constants.rotationDuration).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
            // Reset so the animation restarts if the view reappears with persisted @State.
            .onDisappear { isRotating = false }
    }
}

#Preview {
    VStack(spacing: DesignSystem.shared.spacing.space400) {
        LoadingSpinner(size: .small)
        LoadingSpinner(size: .medium)
        LoadingSpinner(size: .large)
    }
}
