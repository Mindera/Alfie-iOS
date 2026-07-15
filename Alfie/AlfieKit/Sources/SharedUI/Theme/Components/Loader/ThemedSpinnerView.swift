import SwiftUI

/// Static, non-animated loading indicator: a partial ring drawn with a design-system stroke.
/// Motion is intentionally excluded — animating the indicator is deferred to a later story.
public struct ThemedSpinnerView: View {
	private enum Constants {
		static let trimEnd: CGFloat = 0.75
		static let lineWidth: CGFloat = 2
	}

	private let size: CGFloat

	public init(size: CGFloat = Sizing.iconsIconMedium) {
		self.size = size
	}

	public var body: some View {
		Circle()
			.trim(from: 0, to: Constants.trimEnd)
			.stroke(
				theme.color.neutrals400,
				style: StrokeStyle(lineWidth: Constants.lineWidth, lineCap: .round)
			)
			.rotationEffect(.degrees(-90))
			.frame(width: size, height: size)
	}
}

#Preview {
	ThemedSpinnerView()
}
