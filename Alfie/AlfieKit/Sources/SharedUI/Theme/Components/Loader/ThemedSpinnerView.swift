import SwiftUI

/// Design-system loading spinner: a ring whose stroke fades from opaque to transparent
/// (an angular "comet" gradient) and rotates continuously. Reconstructed from the Figma
/// component (Loading Spinner) — SwiftUI's `AngularGradient` is the native equivalent of the
/// design's conic gradient, so it stays crisp at every size and is driven purely by tokens.
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
		/// Stroke thickness as a fraction of the diameter (≈ 3.4 / 48 from the Figma spec).
		static let lineWidthRatio: CGFloat = 0.0702
		/// Fraction of the ring over which the stroke fades opaque → transparent (91.875° / 360°).
		static let fadeEnd: CGFloat = 0.255
		static let rotationDuration: Double = 1
	}

	private let size: Size
	@State private var isRotating = false

	public init(size: Size = .small) {
		self.size = size
	}

	public var body: some View {
		let dimension = size.dimension
		let lineWidth = dimension * Constants.lineWidthRatio

		Circle()
			.inset(by: lineWidth / 2)
			.stroke(
				AngularGradient(
					stops: [
						.init(color: theme.color.neutrals800, location: 0),
						.init(color: theme.color.neutrals800.opacity(0), location: Constants.fadeEnd),
						.init(color: theme.color.neutrals800, location: 1),
					],
					center: .center
				),
				style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
			)
			.frame(width: dimension, height: dimension)
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
