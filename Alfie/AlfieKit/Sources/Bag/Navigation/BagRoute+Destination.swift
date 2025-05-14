import Model
import MyAccount
import ProductDetails
import SwiftUI
import Web
import Wishlist

// swiftlint:disable function_parameter_count
public extension BagRoute {
    @ViewBuilder
    func destination(
        bagViewModel: () -> some BagViewModelProtocol,
        accountViewModel: () -> some AccountViewModelProtocol,
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol,
        wishlistViewModel: () -> some WishlistViewModelProtocol,
        myAccountIntentViewBuilder: @escaping (MyAccountIntent) -> AnyView
    ) -> some View {
        switch self {
        case .bag:
            BagView(viewModel: bagViewModel())

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
// swiftlint:enable function_parameter_count
