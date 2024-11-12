import Core
import Models
import SwiftUI

public struct HorizontalProductCard: View {
    private let image: URL?
    private let designer: String
    private let name: String
    private let colorTitle: String
    private let color: String
    private let sizeTitle: String
    private let size: String
    private let priceType: PriceType

    public init(
        image: URL?,
        designer: String = "",
        name: String = "",
        colorTitle: String = "",
        color: String = "",
        sizeTitle: String = "",
        size: String = "",
        priceType: PriceType
    ) {
        self.image = image
        self.designer = designer
        self.name = name
        self.colorTitle = colorTitle
        self.color = color
        self.sizeTitle = sizeTitle
        self.size = size
        self.priceType = priceType
    }

    public init(product: Product, colorTitle: String = "", sizeTitle: String = "") {
        self.image = product.defaultVariant.media.first?.asImage?.url
        self.designer = product.brand.name
        self.name = product.name
        self.color = product.defaultVariant.colour?.name ?? ""
        self.size = if let size = product.defaultVariant.size {
            "\(size.value) \((size.scale ?? ""))"
        } else {
            ""
        }
        self.priceType = PriceType(from: product)
        self.colorTitle = colorTitle
        self.sizeTitle = sizeTitle
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
        Spacer()
    }

    @ViewBuilder private var productImageView: some View {
        VStack {
            RemoteImage(
                url: image,
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
        Text.build(theme.font.small.normal(designer))
            .lineLimit(Constants.productDesignerLineLimit)
            .accessibilityIdentifier(AccessibilityId.productDesigner)
    }

    private var productNameView: some View {
        Text.build(theme.font.small.normal(name))
            .lineLimit(Constants.productNameLineLimit)
            .foregroundStyle(Colors.primary.mono500)
            .accessibilityIdentifier(AccessibilityId.productName)
    }

    private var productColorView: some View {
        HStack(spacing: Spacing.space100) {
            Text.build(theme.font.tiny.normal(colorTitle))
                .foregroundStyle(Colors.primary.mono500)
            Text.build(theme.font.tiny.normal(color))
                .foregroundStyle(Colors.primary.mono700)
        }
        .lineLimit(Constants.productColorLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productColor)
    }

    private var productSizeView: some View {
        HStack(spacing: Spacing.space100) {
            Text.build(theme.font.tiny.normal(sizeTitle))
                .foregroundStyle(Colors.primary.mono500)
            Text.build(theme.font.tiny.normal(size))
                .foregroundStyle(Colors.primary.mono700)
        }
        .lineLimit(Constants.productSizeLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productSize)
    }

    private var productPriceView: some View {
        PriceComponentView(
            type: priceType,
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
        image: URL(string: "https://www.alfieproj.com/productimages/thumb/1/1262024_22313940_13558933.jpg"),
        designer: "Yves Saint Laurent",
        name: "Rouge Pur Couture",
        colorTitle: "Color:",
        color: "104",
        sizeTitle: "Size:",
        size: "No size",
        priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
    )
}
