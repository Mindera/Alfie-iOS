import Model
import ProductDetails
import Web

public final class BagFlowDependencyContainer {
    let bagDependencyContainer: BagDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let webDependencyContainer: WebDependencyContainer

    public init(
        bagDependencyContainer: BagDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer
    ) {
        self.bagDependencyContainer = bagDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
    }
}
