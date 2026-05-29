import Foundation
import Model

public actor BagService: BagServiceProtocol {
    private let store: BagStoreProtocol
    /// In-memory cache hydrated once from the store; reads served from here, writes persist through.
    private var products: [SelectedProduct]

    public init(store: BagStoreProtocol) {
        self.store = store
        self.products = store.load()
    }

    public func addProduct(_ product: SelectedProduct) {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
        store.save(products)
    }

    public func removeProduct(_ product: SelectedProduct) {
        products = products.filter { $0.id != product.id }
        store.save(products)
    }

    public func getBagContent() -> [SelectedProduct] {
        products
    }
}
