import Foundation
import Models

// TODO: Update with an actual implementation with storage
public final class BagService: BagServiceProtocol {
    private var products: [SelectionProduct] = []

    public init() { }

    public func addProduct(_ product: SelectionProduct) {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
    }

    public func removeProduct(_ product: SelectionProduct) {
        products = products.filter { $0.id != product.id }
    }

    public func getBagContent() -> [SelectionProduct] {
        products
    }
}
