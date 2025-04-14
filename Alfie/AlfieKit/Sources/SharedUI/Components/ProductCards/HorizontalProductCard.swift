import Core
import Model
import SwiftUI

public struct HorizontalProductCard: View {
    private let viewModel: HorizontalProductCardViewModel

    public init(viewModel: HorizontalProductCardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Spacing.space200) {
            productImageView
                .accessibilityIdentifier(AccessibilityId.productImage)
            VStack(alignment: .leading, spacing: Spacing.space0) {
                productDesignerView
                    .padding(.bottom, Spacing.space075)
                productNameView
                    .padding(.bottom, Spacing.space075)
                productColorView
                    .padding(.bottom, Spacing.space075)
                productSizeView
                    .padding(.bottom, Spacing.space100)
                productPriceView
            }

            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productCard)
    }

    @ViewBuilder private var productImageView: some View {
        VStack {
            RemoteImage(
                url: viewModel.image,
                success: { image in
                    image
                        .resizable()
                        .scaledToFit()
                },
                placeholder: { Colors.primary.mono050 },
                failure: { _ in Colors.primary.mono050 }
            )
        }
        .frame(width: Constants.productImageWidth, height: Constants.productImageHeight)
    }

    private var productDesignerView: some View {
        Text.build(theme.font.small.normal(viewModel.designer))
            .lineLimit(Constants.productDesignerLineLimit)
            .accessibilityIdentifier(AccessibilityId.productDesigner)
    }

    private var productNameView: some View {
        Text.build(theme.font.small.normal(viewModel.name))
            .lineLimit(Constants.productNameLineLimit)
            .foregroundStyle(Colors.primary.mono500)
            .accessibilityIdentifier(AccessibilityId.productName)
    }

    private var productColorView: some View {
        HStack(spacing: Spacing.space100) {
            if let colorTitle = viewModel.colorTitle {
                Text.build(theme.font.tiny.normal(colorTitle))
                    .foregroundStyle(Colors.primary.mono500)
            }
            if let color = viewModel.color {
                Text.build(theme.font.tiny.normal(color))
                    .foregroundStyle(Colors.primary.mono700)
            }
        }
        .lineLimit(Constants.productColorLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productColor)
    }

    private var productSizeView: some View {
        HStack(spacing: Spacing.space100) {
            if let sizeTitle = viewModel.sizeTitle {
                Text.build(theme.font.tiny.normal(sizeTitle))
                    .foregroundStyle(Colors.primary.mono500)
            }
            if let size = viewModel.size {
                Text.build(theme.font.tiny.normal(size))
                    .foregroundStyle(Colors.primary.mono700)
            }
        }
        .lineLimit(Constants.productSizeLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productSize)
    }

    private var productPriceView: some View {
        PriceComponentView(
            type: viewModel.priceType,
            configuration: .init(preferredDistribution: .horizontal, size: .small, textAlignment: .leading)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productPrice)
    }
}

private enum AccessibilityId {
    static let productCard = "product-card"
    static let productImage = "product-image"
    static let productDesigner = "product-designer"
    static let productName = "product-name"
    static let productColor = "product-color"
    static let productSize = "product-size"
    static let productPrice = "product-price-component"
}

private enum Constants {
    static let productImageWidth: CGFloat = 75
    static let productImageRatio: CGFloat = 100 / 75
    static var productImageHeight: CGFloat { productImageWidth * productImageRatio }
    static let productDesignerLineLimit: Int = 1
    static let productNameLineLimit: Int = 2
    static let productColorLineLimit: Int = 1
    static let productSizeLineLimit: Int = 1
}

#Preview {
    HorizontalProductCard(
        viewModel: .init(
            image: URL(string: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            designer: "Yves Saint Laurent",
            name: "Rouge Pur Couture",
            colorTitle: "Color:",
            color: "104",
            sizeTitle: "Size:",
            size: "No size",
            priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
        )
    )
}
