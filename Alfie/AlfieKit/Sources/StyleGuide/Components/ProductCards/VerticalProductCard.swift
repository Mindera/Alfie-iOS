import Core
import Models
import SwiftUI

// MARK: - Card View

public struct VerticalProductCard: View {
    public typealias ProductUserActionHandler = (_ product: String, _ type: ProductUserActionType) -> Void
    public enum ProductUserActionType {
        case wishlist(isFavorite: Bool)
        case remove
        case addToBag
    }

    private let viewModel: VerticalProductCardViewModel
    private let onUserAction: ProductUserActionHandler
    private let isFavorite: Bool
    @Binding public private(set) var isSkeleton: Bool

    public init(
        viewModel: VerticalProductCardViewModel,
        onUserAction: @escaping ProductUserActionHandler,
        isSkeleton: Binding<Bool> = .constant(false),
        isFavorite: Bool = false
    ) {
        self.viewModel = viewModel
        self.onUserAction = onUserAction
        self.isFavorite = isFavorite
        self._isSkeleton = isSkeleton
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: viewModel.configuration.verticalInterSpacing) {
            productImageView
                .shimmering(while: $isSkeleton)
                .accessibilityIdentifier(AccessibilityId.productImage)

            HStack(alignment: .lastTextBaseline, spacing: Spacing.space0) {
                VStack(alignment: .leading, spacing: Spacing.space050) {
                    productDesignerView
                    productNameView
                    if !viewModel.configuration.hideColor {
                        productColorView
                    }
                    if !viewModel.configuration.hideSize {
                        productSizeView
                    }
                }

                if viewModel.configuration.size == .large && !viewModel.configuration.hidePrice {
                    Spacer()
                    productPriceView
                    addToBagView
                }
            }

            if viewModel.configuration.size != .large && !viewModel.configuration.hidePrice {
                productPriceView
                addToBagView
            }
        }
        .overlay(alignment: .topTrailing) {
            if !isSkeleton && !viewModel.configuration.hideAction {
                actionView
            }
        }
        .frame(width: viewModel.configuration.cardSize.value)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productCard)
    }

    @ViewBuilder private var productImageView: some View {
        RemoteImage(
            url: viewModel.image,
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
        Text(viewModel.designer)
            .font(Font(viewModel.configuration.textFont))
            .foregroundStyle(Colors.primary.mono900)
            .lineLimit(Constants.productDesignerLineLimit)
            .shimmeringMultiline(
                while: $isSkeleton,
                lines: Constants.productDesignerLineLimit,
                font: viewModel.configuration.textFont
            )
            .accessibilityIdentifier(AccessibilityId.productDesigner)
    }

    @ViewBuilder private var productNameView: some View {
        Text(viewModel.name)
            .font(Font(viewModel.configuration.textFont))
            .foregroundStyle(Colors.primary.mono500)
            .frame(
                height: (viewModel.configuration.textFont.lineHeight * CGFloat(Constants.productNameLineLimit)),
                alignment: .top
            )
            .lineLimit(Constants.productNameLineLimit)
            .shimmeringMultiline(
                while: $isSkeleton,
                lines: Constants.productNameLineLimit,
                font: viewModel.configuration.textFont
            )
            .accessibilityIdentifier(AccessibilityId.productName)
    }

    private var productColorView: some View {
        HStack(spacing: Spacing.space100) {
            if let colorTitle = viewModel.colorTitle {
                Text(colorTitle)
                    .font(Font(viewModel.configuration.smallTextFont))
                    .foregroundStyle(Colors.primary.mono500)
            }
            if let color = viewModel.color {
                Text(color)
                    .font(Font(viewModel.configuration.smallTextFont))
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
                Text(sizeTitle)
                    .font(Font(viewModel.configuration.smallTextFont))
                    .foregroundStyle(Colors.primary.mono500)
            }
            if let size = viewModel.size {
                Text(size)
                    .font(Font(viewModel.configuration.smallTextFont))
                    .foregroundStyle(Colors.primary.mono700)
            }
        }
        .lineLimit(Constants.productSizeLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productSize)
    }

    private var productPriceView: some View {
        PriceComponentView(type: viewModel.priceType, configuration: viewModel.configuration.priceConfiguration)
            .shimmering(while: $isSkeleton)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityId.productPrice)
    }

    @ViewBuilder private var addToBagView: some View {
        if
            let outOfStockTitle = viewModel.outOfStockTitle,
            let addToBagTitle = viewModel.addToBagTitle {
            ThemedButton(
                text: viewModel.isAddToBagDisabled ? outOfStockTitle : addToBagTitle,
                type: .small,
                style: .secondary,
                isDisabled: .init(
                    get: { viewModel.isAddToBagDisabled },
                    set: { _ in }
                ),
                isFullWidth: true
            ) {
                onUserAction(viewModel.productId, .addToBag)
            }
        }
    }

    @ViewBuilder private var actionView: some View {
        switch viewModel.configuration.size {
        case .small:
            EmptyView()
        case .medium,
             .large: // swiftlint:disable:this indentation_width
            let topTrailingEdgePadding = viewModel.configuration.size == .medium ? Spacing.space050 : Spacing.space100
            let iconSize = viewModel.configuration.size == .medium ? Constants.iconSmallSize : Constants.iconLargeSize

            Button(action: {
                // swiftlint:disable vertical_whitespace_between_cases
                switch viewModel.configuration.actionType {
                case .wishlist:
                    onUserAction(viewModel.productId, .wishlist(isFavorite: isFavorite))
                case .remove:
                    onUserAction(viewModel.productId, .remove)
                }
                // swiftlint:enable vertical_whitespace_between_cases
            }, label: {
                actionImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(Colors.primary.black, Colors.primary.white)
            })
            .padding([.top, .trailing], topTrailingEdgePadding)
            .accessibilityIdentifier(actionViewAccessibilityIdentifier)
        }
    }
}

// MARK: - Private Properties

private extension VerticalProductCard {
    var actionImage: Image {
        // swiftlint:disable vertical_whitespace_between_cases
        switch viewModel.configuration.actionType {
        case .wishlist:
            isFavorite ? Icon.heartFill.image : Icon.heart.image
        case .remove:
            Icon.closeCircleFill.image
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    var actionViewAccessibilityIdentifier: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch viewModel.configuration.actionType {
        case .wishlist:
            AccessibilityId.productWishlistButton
        case .remove:
            AccessibilityId.productRemoveFromWishlistButton
        }
        // swiftlint:enable vertical_whitespace_between_cases
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
    static let productWishlistButton = "product-add-wishlist-btn"
    static let productRemoveFromWishlistButton = "product-remove-from-wishlist-btn"
}

private enum Constants {
    static let productDesignerLineLimit: Int = 1
    static let productNameLineLimit: Int = 2
    static let productColorLineLimit: Int = 1
    static let productSizeLineLimit: Int = 1
    static let iconSmallSize: CGFloat = 24
    static let iconLargeSize: CGFloat = 32
    static let imageAspectRatio: CGFloat = 0.75
}

#Preview("Small") {
    VerticalProductCard(
        viewModel: .init(
            configuration: .init(size: .small),
            productId: "1",
            image: URL(string: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            designer: "Yves Saint Laurent",
            name: "Rouge Pur Couture",
            priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
        ),
        onUserAction: { _, _ in },
        isSkeleton: .constant(false)
    )
}

#Preview("Medium") {
    VerticalProductCard(
        viewModel: .init(
            configuration: .init(size: .medium),
            productId: "2",
            image: URL(string: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            designer: "Yves Saint Laurent",
            name: "Rouge Pur Couture",
            priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
        )
    ) { _, _ in }
}

#Preview("Large") {
    VerticalProductCard(
        viewModel: .init(
            configuration: .init(size: .large),
            productId: "3",
            image: URL(string: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            designer: "Yves Saint Laurent",
            name: "Rouge Pur Couture",
            priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
        )
    ) { _, _ in }
}
