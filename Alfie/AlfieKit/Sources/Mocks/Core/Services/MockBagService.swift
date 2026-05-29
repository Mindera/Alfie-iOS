import Foundation
import Model

public final class MockBagService: BagServiceProtocol {
    private var products: [SelectedProduct]

    public init(products: [SelectedProduct] = []) {
        self.products = products
    }

    public func addProduct(_ product: SelectedProduct) async {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
    }

    public func removeProduct(_ product: SelectedProduct) async {
        products = products.filter { $0.id != product.id }
    }

    public func getBagContent() async -> [SelectedProduct] {
        products
    }
}
