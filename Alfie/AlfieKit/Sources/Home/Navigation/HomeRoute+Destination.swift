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
        homeViewModel: () -> some HomeViewModelProtocol,
        accountViewModel: () -> some AccountViewModelProtocol,
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol,
        productListingViewModel: (ProductListingScreenConfiguration) -> some ProductListingViewModelProtocol,
        myAccountIntentViewBuilder: @escaping (MyAccountIntent) -> AnyView,
        wishlistViewModel: () -> some WishlistViewModelProtocol
    ) -> some View {
        switch self {
        case .home:
            HomeView(viewModel: homeViewModel())

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
