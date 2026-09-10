import Model
import MyAccount
import ProductDetails
import ProductListing
import Scanner
import Search
import Web
import Wishlist

public final class HomeFlowDependencyContainer {
    let homeDependencyContainer: HomeDependencyContainer
    let myAccountDependencyContainer: MyAccountDependencyContainer
    let productListingDependencyContainer: ProductListingDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let webDependencyContainer: WebDependencyContainer
    let wishlistDependencyContainer: WishlistDependencyContainer
    let searchDependencyContainer: SearchDependencyContainer
    let scannerDependencyContainer: ScannerDependencyContainer

    public init(
        homeDependencyContainer: HomeDependencyContainer,
        myAccountDependencyContainer: MyAccountDependencyContainer,
        productListingDependencyContainer: ProductListingDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer,
        wishlistDependencyContainer: WishlistDependencyContainer,
        searchDependencyContainer: SearchDependencyContainer,
        scannerDependencyContainer: ScannerDependencyContainer
    ) {
        self.homeDependencyContainer = homeDependencyContainer
        self.myAccountDependencyContainer = myAccountDependencyContainer
        self.productListingDependencyContainer = productListingDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
        self.wishlistDependencyContainer = wishlistDependencyContainer
        self.searchDependencyContainer = searchDependencyContainer
        self.scannerDependencyContainer = scannerDependencyContainer
    }
}
