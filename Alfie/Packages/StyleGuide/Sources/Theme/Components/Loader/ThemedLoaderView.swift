import SwiftUI

public struct ThemedLoaderView: View {
	private enum Constants {
		static let logoFileName = "spin"
		static let logoSize: CGFloat = 100
		static let animationTime: Double = 0.85
	}

	private let labelHidden: Bool
	private let labelTitle: String

	public init(labelHidden: Bool = true, labelTitle: String = "Loading") {
		self.labelHidden = labelHidden
		self.labelTitle = labelTitle
	}

	public var body: some View {
		VStack(spacing: Spacing.space150) {
			if let url = Bundle.module.url(forResource: Constants.logoFileName, withExtension: "gif") {
				AnimatedGifImage(url: url,
								 imageSize: .init(
									width: Constants.logoSize,
									height: Constants.logoSize),
								 animationDuration: Constants.animationTime)
				.frame(width: Constants.logoSize, height: Constants.logoSize)
			}

			if !labelHidden {
				Text.build(theme.font.paragraph.normal(labelTitle))
					.foregroundStyle(Colors.primary.black)
			}
		}
	}
}

#Preview {
	ThemedLoaderView()
}

private struct AnimatedGifImage: UIViewRepresentable {
	let url: URL
	let imageSize: CGSize
	let duration: Double

	init(url: URL, imageSize: CGSize, animationDuration: Double) {
		self.url = url
		self.imageSize = imageSize
		self.duration = animationDuration
	}

	func makeUIView(context: Self.Context) -> UIView {
		let containerView = UIView(frame: .zero)
		let animationImageView = UIImageView(frame: .init(
			x: 0,
			y: 0,
			width: imageSize.width,
			height: imageSize.height))

		animationImageView.clipsToBounds = true
		animationImageView.autoresizesSubviews = true
		animationImageView.contentMode = .scaleAspectFit

		if let data = try? Data(contentsOf: url) {
			animationImageView.image = UIImage.gifImageWithData(data, duration: duration)
		}

		containerView.addSubview(animationImageView)
		return containerView
	}

	func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimatedGifImage>) {
	}
}

private extension UIImage {
	class func gifImageWithData(_ data: Data, duration: CGFloat) -> UIImage? {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
			return nil
		}

		let frameCount = CGImageSourceGetCount(source)
		var images: [UIImage] = []

		for index in 0..<frameCount {
			if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
				let image = UIImage(cgImage: cgImage)
				images.append(image)
			}
		}

		return UIImage.animatedImage(with: images, duration: duration)
	}
}
