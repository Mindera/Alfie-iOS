import Foundation
import Models

public final class MockBagService: BagServiceProtocol {
    private var products: [BagProduct] = []

    public init() { }

    public func addProduct(_ bagProduct: BagProduct) {
        guard !products.contains(where: { $0.id == bagProduct.id }) else { return }

        products.append(bagProduct)
    }

    public func removeProduct(_ bagProduct: BagProduct) {
        products = products.filter { $0.id != bagProduct.id }
    }

    public func getBagContent() -> [BagProduct] {
        products
    }
}
