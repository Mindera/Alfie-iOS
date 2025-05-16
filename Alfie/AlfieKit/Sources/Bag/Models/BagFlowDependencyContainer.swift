import Model
import MyAccount
import ProductDetails
import Web
import Wishlist

public final class BagFlowDependencyContainer {
    let bagDependencyContainer: BagDependencyContainer
    let myAccountDependencyContainer: MyAccountDependencyContainer
    let productDetailsDependencyContainer: ProductDetailsDependencyContainer
    let webDependencyContainer: WebDependencyContainer
    let wishlistDependencyContainer: WishlistDependencyContainer

    public init(
        bagDependencyContainer: BagDependencyContainer,
        myAccountDependencyContainer: MyAccountDependencyContainer,
        productDetailsDependencyContainer: ProductDetailsDependencyContainer,
        webDependencyContainer: WebDependencyContainer,
        wishlistDependencyContainer: WishlistDependencyContainer
    ) {
        self.bagDependencyContainer = bagDependencyContainer
        self.myAccountDependencyContainer = myAccountDependencyContainer
        self.productDetailsDependencyContainer = productDetailsDependencyContainer
        self.webDependencyContainer = webDependencyContainer
        self.wishlistDependencyContainer = wishlistDependencyContainer
    }
}
