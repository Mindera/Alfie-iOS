import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web
import Wishlist

public extension BagRoute {
    @ViewBuilder
    func destination(
        bagViewModel: () -> some BagViewModelProtocol2,
        accountViewModel: () -> some AccountViewModelProtocol2,
        productDetailsViewModel: (ProductDetailsConfiguration2) -> some ProductDetailsViewModelProtocol2,
        webViewModel: (WebFeature) -> some WebViewModelProtocol2,
        wishlistViewModel: () -> some WishlistViewModelProtocol2,
        myAccountIntentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) -> some View {
        switch self {
        case .bag:
            BagView2(viewModel: bagViewModel())

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

        case .wishlist(let wishlistRoute):
            wishlistRoute.destination(
                accountViewModel: accountViewModel,
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel,
                wishlistViewModel: wishlistViewModel,
                myAccountIntentViewBuilder: myAccountIntentViewBuilder
            )
        }
    }
}
