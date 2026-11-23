import AccessibilityIdentifiers
import Core
import Model
import SwiftUI

public struct HorizontalProductCard: View {
    private let viewModel: HorizontalProductCardViewModel

    public init(viewModel: HorizontalProductCardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.sizing.spacingSpacingMd) {
            productImageView
                .accessibilityIdentifier(AccessibilityID.ProductCard.image)
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingNone) {
                productDesignerView
                    .padding(.bottom, theme.sizing.spacingSpacingXs)
                productNameView
                    .padding(.bottom, theme.sizing.spacingSpacingXs)
                productColorView
                    .padding(.bottom, theme.sizing.spacingSpacingXs)
                productSizeView
                    .padding(.bottom, theme.sizing.spacingSpacingXs)
                productPriceView
            }

            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.ProductCard.card)
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
                placeholder: { theme.color.surfaceForegroundPrimary },
                failure: { _ in theme.color.surfaceForegroundPrimary }
            )
        }
        .frame(width: Constants.productImageWidth, height: Constants.productImageHeight)
    }

    private var productDesignerView: some View {
        Text.build(theme.font.body.small(viewModel.designer))
            .lineLimit(Constants.productDesignerLineLimit)
            .accessibilityIdentifier(AccessibilityID.ProductCard.designer)
    }

    private var productNameView: some View {
        Text.build(theme.font.body.small(viewModel.name))
            .lineLimit(Constants.productNameLineLimit)
            .foregroundStyle(theme.color.contentContentTerciary)
            .accessibilityIdentifier(AccessibilityID.ProductCard.name)
    }

    private var productColorView: some View {
        HStack(spacing: theme.sizing.spacingSpacingXs) {
            if let colorTitle = viewModel.colorTitle {
                Text.build(theme.font.body.small(colorTitle))
                    .foregroundStyle(theme.color.contentContentTerciary)
            }
            if let color = viewModel.color {
                Text.build(theme.font.body.small(color))
                    .foregroundStyle(theme.color.contentContentSecondary)
            }
        }
        .lineLimit(Constants.productColorLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.ProductCard.colour)
    }

    private var productSizeView: some View {
        HStack(spacing: theme.sizing.spacingSpacingXs) {
            if let sizeTitle = viewModel.sizeTitle {
                Text.build(theme.font.body.small(sizeTitle))
                    .foregroundStyle(theme.color.contentContentTerciary)
            }
            if let size = viewModel.size {
                Text.build(theme.font.body.small(size))
                    .foregroundStyle(theme.color.contentContentSecondary)
            }
        }
        .lineLimit(Constants.productSizeLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.ProductCard.size)
    }

    private var productPriceView: some View {
        PriceComponentView(
            type: viewModel.priceType,
            configuration: .init(preferredDistribution: .horizontal, size: .small, textAlignment: .leading)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.ProductCard.price)
    }
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
