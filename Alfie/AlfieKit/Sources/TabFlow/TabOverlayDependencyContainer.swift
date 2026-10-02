import ProductDetails
import ProductListing
import Scanner
import Search
import Web

public final class TabOverlayDependencyContainer {
    let search: SearchDependencyContainer
    let scanner: ScannerDependencyContainer
    let productListing: ProductListingDependencyContainer
    let productDetails: ProductDetailsDependencyContainer
    let web: WebDependencyContainer

    public init(
        search: SearchDependencyContainer,
        scanner: ScannerDependencyContainer,
        productListing: ProductListingDependencyContainer,
        productDetails: ProductDetailsDependencyContainer,
        web: WebDependencyContainer
    ) {
        self.search = search
        self.scanner = scanner
        self.productListing = productListing
        self.productDetails = productDetails
        self.web = web
    }
}
