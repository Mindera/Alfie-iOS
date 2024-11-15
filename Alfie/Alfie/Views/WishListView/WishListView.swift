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
            VStack(alignment: .leading, spacing: Spacing.space200) {
                ForEach(mockContent.wishlistProducts) { product in
                    HorizontalProductCard(
                        product: product,
                        colorTitle: LocalizableProductDetails.$color + ":",
                        sizeTitle: LocalizableProductDetails.$size + ":",
                        oneSizeTitle: LocalizableProductDetails.$oneSize
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

#Preview {
    WishListView()
        .environmentObject(Coordinator())
}
