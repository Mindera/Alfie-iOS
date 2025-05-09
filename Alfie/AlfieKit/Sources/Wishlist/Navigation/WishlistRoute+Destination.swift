import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web

public extension WishlistRoute {
    @ViewBuilder
    func destination(
        accountViewModel: () -> some AccountViewModelProtocol2,
        productDetailsViewModel: (String, Product?) -> some ProductDetailsViewModelProtocol2,
        webViewModel: (WebFeature) -> some WebViewModelProtocol2,
        wishlistViewModel: () -> some WishlistViewModelProtocol2,
        myAccountIntentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) -> some View {
        switch self {
        case .myAccount(let myAccountRoute):
            myAccountRoute.destination(
                accountViewModel: accountViewModel,
                intentViewBuilder: myAccountIntentViewBuilder
            )

        case .productDetails(let productDetailsRoute):
            productDetailsRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel
            )

        case .wishlist:
            WishlistView2(viewModel: wishlistViewModel())
        }
    }
}
