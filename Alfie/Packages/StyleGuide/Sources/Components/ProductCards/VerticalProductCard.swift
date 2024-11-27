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

    public enum ActionType {
        case wishlist
        case remove
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
    let hideDetails: Bool
    let actionType: ActionType

    public init(
        size: Size,
        hidePrice: Bool = false,
        hideAction: Bool = false,
        hideDetails: Bool = true,
        actionType: ActionType = .wishlist
    ) {
        self.size = size
        self.hidePrice = hidePrice
        self.hideAction = hideAction
        self.hideDetails = hideDetails
        self.actionType = actionType
    }

    // swiftlint:disable vertical_whitespace_between_cases
    var cardSize: CardIntrinsicSize {
        switch size {
        case .small:
            .fixed(size: 130)
        case .medium,
             .large: // swiftlint:disable:this indentation_width
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
             .medium: // swiftlint:disable:this indentation_width
            ThemeProvider.shared.font.small.normal
        case .large:
            ThemeProvider.shared.font.paragraph.normal
        }
    }

    var smallTextFont: UIFont {
        switch size {
        case .small,
             .medium: // swiftlint:disable:this indentation_width
            ThemeProvider.shared.font.tiny.normal
        case .large:
            ThemeProvider.shared.font.small.normal
        }
    }
    // swiftlint:enable vertical_whitespace_between_cases
}

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
    @Binding public private(set) var isSkeleton: Bool
    @Binding private var isFavorite: Bool

    public init(
        viewModel: VerticalProductCardViewModel,
        onUserAction: @escaping ProductUserActionHandler,
        isSkeleton: Binding<Bool> = .constant(false),
        isFavorite: Binding<Bool> = .constant(false)
    ) {
        self.viewModel = viewModel
        self.onUserAction = onUserAction
        self._isSkeleton = isSkeleton
        self._isFavorite = isFavorite
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
                    if !viewModel.configuration.hideDetails {
                        productColorView
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
            Text(viewModel.colorTitle)
                .font(Font(viewModel.configuration.smallTextFont))
                .foregroundStyle(Colors.primary.mono500)
            Text(viewModel.color)
                .font(Font(viewModel.configuration.smallTextFont))
                .foregroundStyle(Colors.primary.mono700)
        }
        .lineLimit(Constants.productColorLineLimit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityId.productColor)
    }

    private var productSizeView: some View {
        HStack(spacing: Spacing.space100) {
            Text(viewModel.sizeTitle)
                .font(Font(viewModel.configuration.smallTextFont))
                .foregroundStyle(Colors.primary.mono500)
            Text(viewModel.size)
                .font(Font(viewModel.configuration.smallTextFont))
                .foregroundStyle(Colors.primary.mono700)
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
        if !viewModel.configuration.hideDetails {
            ThemedButton(
                text: viewModel.isAddToBagDisabled ? viewModel.outOfStockTitle : viewModel.addToBagTitle,
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
                switch viewModel.configuration.actionType {
                case .wishlist:
                    isFavorite.toggle()
                    onUserAction(viewModel.productId, .wishlist(isFavorite: isFavorite))

                case .remove:
                    onUserAction(viewModel.productId, .remove)
                }
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
            image: URL(string: "https://www.alfieproj.com/productimages/thumb/1/1262024_22313940_13558933.jpg"),
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
            image: URL(string: "https://www.alfieproj.com/productimages/medium/1/1262024_22313940_13558933.jpg"),
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
            image: URL(string: "https://www.alfieproj.com/productimages/medium/1/1262024_22313940_13558933.jpg"),
            designer: "Yves Saint Laurent",
            name: "Rouge Pur Couture",
            priceType: .formattedRange(lowerBound: 65, upperBound: 68, currencyCode: "AUD")
        )
    ) { _, _ in }
}
