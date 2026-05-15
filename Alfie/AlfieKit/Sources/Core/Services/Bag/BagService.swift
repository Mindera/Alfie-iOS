import Foundation
import Model

public final class BagService: BagServiceProtocol {
    private let store: BagStoreProtocol

    public init(store: BagStoreProtocol) {
        self.store = store
    }

    public func addProduct(_ product: SelectedProduct) {
        var products = store.load()
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
        store.save(products)
    }

    public func removeProduct(_ product: SelectedProduct) {
        let products = store.load().filter { $0.id != product.id }
        store.save(products)
    }

    public func getBagContent() -> [SelectedProduct] {
        store.load()
    }
}
