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

    @discardableResult
    public func removeProduct(withId productId: String) -> WishlistRemoval? {
        let removal = WishlistRemoval(productId: productId, from: products)
        products = products.filter { $0.product.id != productId }
        store.save(products)
        return removal
    }

    public func restore(_ removal: WishlistRemoval) {
        products = removal.restored(into: products)
        store.save(products)
    }

    public func getWishlistContent() -> [SelectedProduct] {
        products
    }
}
