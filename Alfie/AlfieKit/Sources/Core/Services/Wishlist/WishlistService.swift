import Foundation
import Model

public final class WishlistService: WishlistServiceProtocol {
    private let store: WishlistStoreProtocol

    public init(store: WishlistStoreProtocol) {
        self.store = store
    }

    public func addProduct(_ product: SelectedProduct) {
        var products = store.load()
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
        store.save(products)
    }

    public func removeProduct(withId productId: String) {
        let products = store.load().filter { $0.product.id != productId }
        store.save(products)
    }

    public func getWishlistContent() -> [SelectedProduct] {
        store.load()
    }
}
