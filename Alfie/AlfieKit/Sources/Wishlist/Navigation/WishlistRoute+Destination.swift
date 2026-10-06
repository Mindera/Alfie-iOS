import Model
import ProductDetails
import SwiftUI
import Web

public extension WishlistRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol,
        wishlistViewModel: () -> some WishlistViewModelProtocol
    ) -> some View {
        switch self {
        case .productDetails(let productDetailsRoute):
            productDetailsRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel
            )

        case .wishlist:
            WishlistView(viewModel: wishlistViewModel())
        }
    }
}
