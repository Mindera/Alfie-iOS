import Core
import Model
import ProductDetails
import Search
import Web

public final class ProductListingFlowDependencyContainer {
    let productListingDependencyContainer: ProductListingDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let webDependencyContainer: WebDependencyContainer
    let searchDependencyContainer: SearchDependencyContainer

    public init(
        productListingDependencyContainer: ProductListingDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer,
        searchDependencyContainer: SearchDependencyContainer
    ) {
        self.productListingDependencyContainer = productListingDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
        self.searchDependencyContainer = searchDependencyContainer
    }
}
