import Model
import MyAccount
import ProductDetails
import ProductListing
import SwiftUI
import Web
import Wishlist

// swiftlint:disable function_parameter_count
public extension HomeRoute {
    @ViewBuilder
    func destination(
        accountViewModel: () -> some AccountViewModelProtocol2,
        productDetailsViewModel: (ProductDetailsConfiguration2) -> some ProductDetailsViewModelProtocol2,
        webViewModel: (WebFeature) -> some WebViewModelProtocol2,
        productListingViewModel: (ProductListingScreenConfiguration2) -> some ProductListingViewModelProtocol2,
        myAccountIntentViewBuilder: @escaping (MyAccountIntent) -> AnyView,
        wishlistViewModel: () -> some WishlistViewModelProtocol2
    ) -> some View {
        switch self {
        case .myAccount(let myAccountRoute):
            myAccountRoute.destination(
                accountViewModel: accountViewModel,
                intentViewBuilder: myAccountIntentViewBuilder
            )

        case .productListing(let productListingRoute):
            productListingRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel,
                productListingViewModel: productListingViewModel
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
