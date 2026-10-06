import Model
import ProductDetails
import Web

public final class WishlistFlowDependencyContainer {
    let wishlistDependencyContainer: WishlistDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let webDependencyContainer: WebDependencyContainer

    public init(
        wishlistDependencyContainer: WishlistDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer
    ) {
        self.wishlistDependencyContainer = wishlistDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
    }
}
