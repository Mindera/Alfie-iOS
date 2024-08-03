import Core
import Models
import SwiftUI

// MARK: - Configuration

public struct VerticalProductCardConfiguration {
    public enum Size {
        case small
        case medium
        case large
    }

    enum CardIntrinsicSize {
        case fixed(size: CGFloat)
        case flexible

        var value: CGFloat? {
            guard case .fixed(let size) = self else {
                return nil
            }
            return size
        }
    }

    let size: Size
    let hidePrice: Bool
    let hideAction: Bool

    public init(size: Size, hidePrice: Bool = false, hideAction: Bool = false) {
        self.size = size
        self.hidePrice = hidePrice
        self.hideAction = hideAction
    }

    // swiftlint:disable vertical_whitespace_between_cases
    var cardSize: CardIntrinsicSize {
        switch size {
        case .small:
            .fixed(size: 130)
        case .medium,
            .large:
            .flexible
        }
    }

    var verticalInterSpacing: CGFloat {
        switch size {
        case .small:
            Spacing.space100
        case .medium:
            Spacing.space150
        case .large:
            Spacing.space200
        }
    }

    var priceConfiguration: PriceConfiguration {
        switch size {
        case .small:
            .init(preferredDistribution: .horizontal, size: .small, textAlignment: .leading)
        case .medium:
            .init(preferredDistribution: .horizontal, size: .large, textAlignment: .leading)
        case .large:
            .init(preferredDistribution: .vertical, size: .large, textAlignment: .trailing)
        }
    }

    var textFont: UIFont {
        switch size {
        case .small,
            .medium:
            ThemeProvider.shared.font.small.normal
        case .large:
            ThemeProvider.shared.font.paragraph.normal
        }
    }
    // swiftlint:enable vertical_whitespace_between_cases
}

// MARK: - Card View

public struct VerticalProductCard: View {
    public typealias ProductUserActionHandler = (_ product: String, _ type: ProductUserActionType) -> Void
    public enum ProductUserActionType {
        case wishlist(isFavorite: Bool)
    }

    private let configuration: VerticalProductCardConfiguration
    private let productId: String
    private let image: URL?
    private let designer: String
    private let name: String
    private let priceType: PriceType
    private let onUserAction: ProductUserActionHandler
    @Binding public private(set) var isSkeleton: Bool

    public init(
        configuration: VerticalProductCardConfiguration,
        productId: String,
        image: URL?,
        designer: String,
        name: String,
        priceType: PriceType,
        onUserAction: @escaping ProductUserActionHandler,
        isSkeleton: Binding<Bool> = .constant(false)
    ) {
        self.configuration = configuration
        self.productId = productId
        self.image = image
        self.designer = designer
        self.name = name
        self.priceType = priceType
        self.onUserAction = onUserAction
        self._isSkeleton = isSkeleton
    }

    public init(
        configuration: VerticalProductCardConfiguration,
        product: Product,
        onUserAction: @escaping ProductUserActionHandler,
        isSkeleton: Binding<Bool> = .constant(false)
    ) {
        self.configuration = configuration
        self.productId = product.id
        self.image = product.defaultVariant.media.first?.asImage?.url
        self.designer = product.brand.name
        self.name = product.name
        self.priceType = PriceType(from: product)
        self.onUserAction = onUserAction
        self._isSkeleton = isSkeleton
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: configuration.verticalInterSpacing) {
            productImageView
                .shimmering(while: $isSkeleton)
                .accessibilityIdentifier(AccessibilityId.productImage)

            HStack(alignment: .lastTextBaseline, spacing: Spacing.space0) {
                VStack(alignment: .leading, spacing: Spacing.space050) {
                    productDesignerView
                    productNameView
                }

                if configuration.size == .large && !configuration.hidePrice {
                    Spacer()
                    productPriceView
                }
            }

            if configuration.size != .large && !configuration.hidePrice {
                productPriceView
            }
        }
        .overlay(alignment: .topTrailing) {
            if !isSkeleton && !configuration.hideAction {
                wishlistView
            }
        }
        .frame(width: configuration.cardSize.value)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productCard)
    }

    @ViewBuilder private var productImageView: some View {
        RemoteImage(
            url: image,
            success: { image in
                image
                    .resizable()
                    .aspectRatio(Constants.imageAspectRatio, contentMode: .fit)
            },
            placeholder: { Colors.primary.mono050 },
            failure: { _ in Colors.primary.mono050 }
        )
        .aspectRatio(Constants.imageAspectRatio, contentMode: .fill)
    }

    private var productDesignerView: some View {
        Text(designer)
            .font(Font(configuration.textFont))
            .foregroundStyle(Colors.primary.mono900)
            .lineLimit(Constants.productDesignerLineLimit)
            .shimmeringMultiline(
                while: $isSkeleton,
                lines: Constants.productDesignerLineLimit,
                font: configuration.textFont
            )
            .accessibilityIdentifier(AccessibilityId.productDesigner)
    }

    @ViewBuilder private var productNameView: some View {
        Text(name)
            .font(Font(configuration.textFont))
            .foregroundStyle(Colors.primary.mono500)
            .frame(
                height: (configuration.textFont.lineHeight * CGFloat(Constants.productNameLineLimit)), alignment: .top
            )
            .lineLimit(Constants.productNameLineLimit)
            .shimmeringMultiline(
                while: $isSkeleton,
                lines: Constants.productNameLineLimit,
                font: configuration.textFont
            )
            .accessibilityIdentifier(AccessibilityId.productName)
    }

    private var productPriceView: some View {
        PriceComponentView(type: priceType, configuration: configuration.priceConfiguration)
            .shimmering(while: $isSkeleton)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityId.productPrice)
    }

    @ViewBuilder private var wishlistView: some View {
        switch configuration.size {
        case .small:
            EmptyView()
        case .medium,
            .large:
            let topTrailingEdgePadding = configuration.size == .medium ? Spacing.space050 : Spacing.space100
            let iconSize = configuration.size == .medium ? Constants.iconSmallSize : Constants.iconLargeSize

            Button(action: {
                onUserAction(productId, .wishlist(isFavorite: true))
            }, label: {
                Icon.heart.image
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            })
            .padding([.top, .trailing], topTrailingEdgePadding)
            .accessibilityIdentifier(AccessibilityId.productWishlistButton)
        }
    }
}

private enum AccessibilityId {
    static let productCard = "product-card"
    static let productImage = "product-image"
    static let productDesigner = "product-designer"
    static let productName = "product-name"
    static let productPrice = "product-price-component"
    static let productWishlistButton = "product-add-wishlist-btn"
}

private enum Constants {
    static let productDesignerLineLimit: Int = 1
    static let productNameLineLimit: Int = 2
    static let iconSmallSize: CGFloat = 16
    static let iconLargeSize: CGFloat = 24
    static let imageAspectRatio: CGFloat = 0.75
}

#Preview("Small") {
    VerticalProductCard(
        configuration: .init(size: .small),
        productId: "1",
        image: URL(string: "https://www.alfieproj.com/productimages/thumb/1/1262024_22313940_13558933.jpg"),
        designer: "Yves Saint Laurent",
        name: "Rouge Pur Couture",
        priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD"),
        onUserAction: { _, _ in },
        isSkeleton: .constant(false)
    )
}

#Preview("Medium") {
    VerticalProductCard(
        configuration: .init(size: .medium),
        productId: "2",
        image: URL(string: "https://www.alfieproj.com/productimages/medium/1/1262024_22313940_13558933.jpg"),
        designer: "Yves Saint Laurent",
        name: "Rouge Pur Couture",
        priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
    ) { _, _ in }
}

#Preview("Large") {
    VerticalProductCard(
        configuration: .init(size: .large),
        productId: "3",
        image: URL(string: "https://www.alfieproj.com/productimages/medium/1/1262024_22313940_13558933.jpg"),
        designer: "Yves Saint Laurent",
        name: "Rouge Pur Couture",
        priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
    ) { _, _ in }
}
