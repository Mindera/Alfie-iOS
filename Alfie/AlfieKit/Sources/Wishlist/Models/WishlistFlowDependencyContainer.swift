import Core
import Model
import MyAccount
import ProductDetails
import Web

public final class WishlistFlowDependencyContainer {
    let wishlistDependencyContainer: WishlistDependencyContainer
    let myAccountDependencyContainer: MyAccountDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let webDependencyContainer: WebDependencyContainer

    public init(
        wishlistDependencyContainer: WishlistDependencyContainer,
        myAccountDependencyContainer: MyAccountDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer
    ) {
        self.wishlistDependencyContainer = wishlistDependencyContainer
        self.myAccountDependencyContainer = myAccountDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
    }
}
