import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct WishListView: View {
    #if DEBUG
    @EnvironmentObject var mockContent: MockContent
    #endif

    var body: some View {
    #if DEBUG
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top),
                    count: 2
                ),
                spacing: Spacing.space200
            ) {
                ForEach(mockContent.wishlistProducts) { product in
                    VerticalProductCard(
                        configuration: .init(size: .medium, hideDetails: false, actionType: .remove),
                        product: product,
                        onUserAction: { _, type in
                            handleUserAction(forProduct: product, actionType: type)
                        },
                        colorTitle: LocalizableGeneral.$color + ":",
                        sizeTitle: LocalizableGeneral.$size + ":",
                        oneSizeTitle: LocalizableGeneral.$oneSize,
                        addToBagTitle: LocalizableGeneral.$addToBag,
                        outOfStockTitle: LocalizableGeneral.$outOfStock,
                        isAddToBagDisabled: product.defaultVariant.stock == .zero
                    )
                }
            }
            .padding(.horizontal, Spacing.space200)
        }
        .padding(.vertical, Spacing.space200)
        .withToolbar(for: .wishlist)
    #else
        VStack {
            Icon.heart.image
                .resizable()
                .scaledToFit()
                .frame(width: 75)
            Text.build(theme.font.header.h3(LocalizableWishList.title))
        }
        .padding(.horizontal, Spacing.space200)
        .withToolbar(for: .wishlist)
    #endif
    }
}

// MARK: - Private Methods

private extension WishListView {
    func handleUserAction(forProduct product: Product, actionType: VerticalProductCard.ProductUserActionType) {
        switch actionType {
        case .remove:
            mockContent.wishlistProducts = mockContent.wishlistProducts.filter { $0.id != product.id }

        case .addToBag:
            guard !mockContent.bagProducts.contains(
                where: {
                    $0.defaultVariant.colour?.id == product.defaultVariant.colour?.id &&
                    $0.defaultVariant.size?.id == product.defaultVariant.size?.id
                }
            )
            else {
                return
            }
            mockContent.bagProducts.append(product)

        case .wishlist:
            return
        }
    }
}

#Preview {
    WishListView()
        .environmentObject(Coordinator())
}
