import Foundation
import Model

// TODO: Update with an actual implementation with storage
public final class BagService: BagServiceProtocol {
    private var products: [SelectedProduct] = []

    public init() { }

    public func addProduct(_ product: SelectedProduct) {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
    }

    public func removeProduct(_ product: SelectedProduct) {
        products = products.filter { $0.id != product.id }
    }

    public func getBagContent() -> [SelectedProduct] {
        products
    }
}
