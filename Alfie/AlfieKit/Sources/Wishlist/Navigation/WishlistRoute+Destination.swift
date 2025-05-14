import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web

public extension WishlistRoute {
    @ViewBuilder
    func destination(
        accountViewModel: () -> some AccountViewModelProtocol,
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol,
        wishlistViewModel: () -> some WishlistViewModelProtocol,
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
            WishlistView(viewModel: wishlistViewModel())
        }
    }
}
