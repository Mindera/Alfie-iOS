import StyleGuide
import SwiftUI

struct WishListView: View {
    var body: some View {
        VStack {
            Icon.heart.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75)
            Text.build(theme.font.header.h3(LocalizableWishList.title))
        }
        .padding(.horizontal, Spacing.space200)
        .withToolbar(for: .wishlist)
    }
}

#Preview {
    WishListView()
        .environmentObject(Coordinator())
}
