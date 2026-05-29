import Foundation
import Model

public actor WishlistService: WishlistServiceProtocol {
    private let store: WishlistStoreProtocol
    /// In-memory cache hydrated once from the store; reads served from here, writes persist through.
    private var products: [SelectedProduct]

    public init(store: WishlistStoreProtocol) {
        self.store = store
        self.products = store.load()
    }

    public func addProduct(_ product: SelectedProduct) {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
        store.save(products)
    }

    public func removeProduct(withId productId: String) {
        products = products.filter { $0.product.id != productId }
        store.save(products)
    }

    public func getWishlistContent() -> [SelectedProduct] {
        products
    }
}
