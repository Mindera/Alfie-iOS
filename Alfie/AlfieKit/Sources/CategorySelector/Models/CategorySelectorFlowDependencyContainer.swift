import Core
import Model
import MyAccount
import ProductDetails
import ProductListing
import Search
import Web
import Wishlist

public final class CategorySelectorFlowDependencyContainer {
    let categorySelectorDependencyContainer: CategorySelectorDependencyContainer
    let webDependencyContainer: WebDependencyContainer
    let myAccountDependencyContainer: MyAccountDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let productListingDependencyContainer: ProductListingDependencyContainer
    let wishlistDependencyContainer: WishlistDependencyContainer
    let searchDependencyContainer: SearchDependencyContainer

    public init(
        categorySelectorDependencyContainer: CategorySelectorDependencyContainer,
        webDependencyContainer: WebDependencyContainer,
        myAccountDependencyContainer: MyAccountDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        productListingDependencyContainer: ProductListingDependencyContainer,
        wishlistDependencyContainer: WishlistDependencyContainer,
        searchDependencyContainer: SearchDependencyContainer
    ) {
        self.categorySelectorDependencyContainer = categorySelectorDependencyContainer
        self.webDependencyContainer = webDependencyContainer
        self.myAccountDependencyContainer = myAccountDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.productListingDependencyContainer = productListingDependencyContainer
        self.wishlistDependencyContainer = wishlistDependencyContainer
        self.searchDependencyContainer = searchDependencyContainer
    }
}
