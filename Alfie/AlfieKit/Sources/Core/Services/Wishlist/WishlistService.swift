import Foundation
import Models

// TODO: Update with an actual implementation with storage
public final class WishlistService: WishlistServiceProtocol {
    private var products: [SelectionProduct] = []

    public init() { }

    public func addProduct(_ product: SelectionProduct) {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
    }

    public func removeProduct(_ productId: String) {
        products = products.filter { $0.id != productId }
    }

    public func getWishlistContent() -> [SelectionProduct] {
        products
    }
}
