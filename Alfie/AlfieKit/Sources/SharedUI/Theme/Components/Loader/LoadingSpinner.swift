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
        // Time-driven rotation: no lifecycle state, so it restarts correctly whenever it reappears.
        TimelineView(.animation) { context in
            Image(ThemedImage.loadingSpinner.literalName, bundle: ThemedImage.loadingSpinner.bundle)
                .resizable()
                .scaledToFit()
                .frame(width: dimension, height: dimension)
                .rotationEffect(angle(at: context.date))
        }
    }

    private func angle(at date: Date) -> Angle {
        let turns = date.timeIntervalSinceReferenceDate / Constants.rotationDuration
        return .degrees(turns.truncatingRemainder(dividingBy: 1) * 360)
    }
}

#Preview {
    VStack(spacing: DesignSystem.shared.spacing.space400) {
        LoadingSpinner(size: .small)
        LoadingSpinner(size: .medium)
        LoadingSpinner(size: .large)
    }
}
