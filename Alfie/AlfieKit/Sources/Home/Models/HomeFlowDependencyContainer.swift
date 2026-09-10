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
    /// The flow opens a scanned link itself rather than letting the scanner do it, so the
    /// navigation stays where every other route in this flow is decided.
    let deepLinkService: DeepLinkServiceProtocol

    public init(
        homeDependencyContainer: HomeDependencyContainer,
        myAccountDependencyContainer: MyAccountDependencyContainer,
        productListingDependencyContainer: ProductListingDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer,
        wishlistDependencyContainer: WishlistDependencyContainer,
        searchDependencyContainer: SearchDependencyContainer,
        scannerDependencyContainer: ScannerDependencyContainer,
        deepLinkService: DeepLinkServiceProtocol
    ) {
        self.homeDependencyContainer = homeDependencyContainer
        self.myAccountDependencyContainer = myAccountDependencyContainer
        self.productListingDependencyContainer = productListingDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
        self.wishlistDependencyContainer = wishlistDependencyContainer
        self.searchDependencyContainer = searchDependencyContainer
        self.scannerDependencyContainer = scannerDependencyContainer
        self.deepLinkService = deepLinkService
    }
}
