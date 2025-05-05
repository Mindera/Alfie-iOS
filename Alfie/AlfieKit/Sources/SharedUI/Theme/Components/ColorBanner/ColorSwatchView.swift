import Core
import Model
import SwiftUI

// MARK: - ColorSwatchView

public struct ColorSwatchView: View {
    public enum SwatchSize {
        /// 24pts
        case small
        /// 32 pts
        case normal
        /// 44pts
        case large
    }

    private let item: ColorSwatch
    private let isSelected: Bool
    private let swatchSize: SwatchSize

    public init(item: ColorSwatch, swatchSize: SwatchSize, isSelected: Bool) {
        self.item = item
        self.swatchSize = swatchSize
        self.isSelected = isSelected
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size / 2)
                .stroke(isSelected ? Colors.primary.black : .clear, lineWidth: Constants.borderLineWidth)
            RoundedRectangle(cornerRadius: size - (Constants.borderLineWidth * 2) / 2)
                .inset(by: Constants.borderLineWidth)
                .stroke(isSelected ? Colors.primary.white : .clear, lineWidth: Constants.borderLineWidth)
        }
        .background {
            ZStack {
                switch item.type {
                case .image(let image):
                    image
                        .resizable()
                        .clipShape(Circle())
                        .clipped(antialiased: true)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)

                case .color(let color):
                    RoundedRectangle(cornerRadius: size / 2)
                        .fill(color)

                case .url(let url):
                    RemoteImage(
                        url: url,
                        success: { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .clipped(antialiased: true)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size, height: size)
                        },
                        placeholder: { Colors.primary.mono050 },
                        failure: { _ in Colors.primary.black }
                    )
                }

                if item.isDisabled {
                    RoundedRectangle(cornerRadius: size / 2)
                        .fill(Color.white)
                        .opacity(Constants.disabledOpacity)
                    theme.shape.unavailableCrossedOutShape()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: size, height: size)
                }
            }
        }
        .frame(width: size, height: size)
    }

    private var size: CGFloat {
        // swiftlint:disable vertical_whitespace_between_cases
        switch swatchSize {
        case .small:
            Constants.swatchSmallSize
        case .normal:
            Constants.swatchNormalSize
        case .large:
            Constants.swatchLargeSize
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

private enum Constants {
    static let borderInset: CGFloat = 3
    static let borderLineWidth: CGFloat = 1
    static let swatchSmallSize: CGFloat = 24
    static let swatchNormalSize: CGFloat = 32
    static let swatchLargeSize: CGFloat = 44
    static let disabledOpacity: CGFloat = 0.75
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        ColorSwatchView(
            item: .init(id: "1", name: "Default", type: .color(.red)),
            swatchSize: .normal,
            isSelected: false
        )

        ColorSwatchView(
            item: .init(id: "2", name: "Selected", type: .color(.green)),
            swatchSize: .normal,
            isSelected: true
        )

        ColorSwatchView(
            item: .init(id: "3", name: "Selected", type: .color(.green), isDisabled: true),
            swatchSize: .normal,
            isSelected: true
        )
    }
}
