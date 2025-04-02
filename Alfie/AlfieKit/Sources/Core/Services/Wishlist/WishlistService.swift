import Foundation
import Models

// TODO: Update with an actual implementation with storage
public final class WishlistService: WishlistServiceProtocol {
    private var products: [WishlistProduct] = []

    public init() { }

    public func addProduct(_ wishlistProduct: WishlistProduct) {
        guard !products.contains(where: { $0.id == wishlistProduct.id }) else { return }

        products.append(wishlistProduct)
    }

    public func removeProduct(_ wishlistProduct: WishlistProduct) {
        products = products.filter { $0.id != wishlistProduct.id }
    }

    public func removeProductVariants(_ wishlistProduct: WishlistProduct) {
        products = products.filter { $0.product.id != wishlistProduct.product.id }
    }

    public func getWishlistContent() -> [WishlistProduct] {
        products
    }
}
