import Foundation
import Models

public final class MockBagService: BagServiceProtocol {
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
