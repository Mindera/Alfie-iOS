import SwiftUI

/// Design-system loading spinner: the Figma Loading Spinner artwork — an angular "comet" ring that
/// fades opaque → transparent — rotated continuously. Sizes S/M/L (24/32/48) per the design.
public struct ThemedSpinnerView: View {
    public enum Size {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: Sizing.iconsIconMedium      // 24
            case .medium: Sizing.iconsIconLarge      // 32
            case .large: Primitives.Spacing.spacing48 // 48
            }
        }
    }

    private enum Constants {
        static let rotationDuration: Double = 1
    }

    private let size: Size
    @State private var isRotating = false

    public init(size: Size = .small) {
        self.size = size
    }

    public var body: some View {
        Image(ThemedImage.loadingSpinner.literalName, bundle: ThemedImage.loadingSpinner.bundle)
            .resizable()
            .scaledToFit()
            .frame(width: size.dimension, height: size.dimension)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: Constants.rotationDuration).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
    }
}

#Preview {
    VStack(spacing: Primitives.Spacing.spacing32) {
        ThemedSpinnerView(size: .small)
        ThemedSpinnerView(size: .medium)
        ThemedSpinnerView(size: .large)
    }
}
