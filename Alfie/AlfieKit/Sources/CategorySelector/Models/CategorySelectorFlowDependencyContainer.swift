import AlicerceLogging
import Model
import MyAccount
import ProductDetails
import ProductListing
import Scanner
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
    let scannerDependencyContainer: ScannerDependencyContainer
    /// The flow opens a scanned link itself rather than letting the scanner do it, so the
    /// navigation stays where every other route in this flow is decided.
    let deepLinkService: DeepLinkServiceProtocol
    let log: Logger

    public init(
        categorySelectorDependencyContainer: CategorySelectorDependencyContainer,
        webDependencyContainer: WebDependencyContainer,
        myAccountDependencyContainer: MyAccountDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        productListingDependencyContainer: ProductListingDependencyContainer,
        wishlistDependencyContainer: WishlistDependencyContainer,
        searchDependencyContainer: SearchDependencyContainer,
        scannerDependencyContainer: ScannerDependencyContainer,
        deepLinkService: DeepLinkServiceProtocol,
        log: Logger
    ) {
        self.categorySelectorDependencyContainer = categorySelectorDependencyContainer
        self.webDependencyContainer = webDependencyContainer
        self.myAccountDependencyContainer = myAccountDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.productListingDependencyContainer = productListingDependencyContainer
        self.wishlistDependencyContainer = wishlistDependencyContainer
        self.searchDependencyContainer = searchDependencyContainer
        self.scannerDependencyContainer = scannerDependencyContainer
        self.deepLinkService = deepLinkService
        self.log = log
    }
}
