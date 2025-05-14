import Model
import MyAccount
import ProductDetails
import ProductListing
import SwiftUI
import Web
import Wishlist

// swiftlint:disable function_parameter_count
public extension CategorySelectorRoute {
    @ViewBuilder
    func destination(
        isRoot: Bool,
        isWishlistEnabled: Bool,
        categoriesViewModel: () -> some CategoriesViewModelProtocol,
        brandsViewModel: () -> some BrandsViewModelProtocol,
        isStoreServicesEnabled: Bool,
        servicesViewModel: () -> some WebViewModelProtocol,
        accountViewModel: () -> some AccountViewModelProtocol,
        myAccountIntentViewBuilder: @escaping (MyAccountIntent) -> AnyView,
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        productListingViewModel: (ProductListingScreenConfiguration) -> some ProductListingViewModelProtocol,
        subCategoriesViewModel: ([NavigationItem], NavigationItem) -> some CategoriesViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol,
        urlWebViewModel: (URL, String) -> some WebViewModelProtocol,
        wishlistViewModel: () -> some WishlistViewModelProtocol,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) -> some View {
        switch self {
        case .categorySelector:
            ShopView(
                isRoot: isRoot,
                isWishlistEnabled: isWishlistEnabled,
                categoriesViewModel: categoriesViewModel(),
                brandsViewModel: brandsViewModel(),
                servicesViewModel: isStoreServicesEnabled ? servicesViewModel() : nil
            ) {
                navigate($0)
            }

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

        case .productListing(let productListingRoute):
            productListingRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel,
                productListingViewModel: productListingViewModel
            )

        case .subCategories(let subCategories, let parent):
            CategoriesView(viewModel: subCategoriesViewModel(subCategories, parent))

        case .web(let url, let title):
            WebView(viewModel: urlWebViewModel(url, title))
                .toolbarView(title: title)

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
