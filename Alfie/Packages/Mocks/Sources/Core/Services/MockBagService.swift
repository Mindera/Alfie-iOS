import Foundation
import Models

public final class MockBagService: BagServiceProtocol {
    private var products: [SelectionProduct] = []

    public init() { }

    public func addProduct(_ product: SelectionProduct) {
        guard !products.contains(
            where: {
                $0.colour?.id == product.colour?.id &&
                $0.size?.id == product.size?.id
            }
        )
        else {
            return
        }

        products.append(product)
    }

    public func removeProduct(_ productId: String) {
        products = products.filter { $0.id != productId }
    }

    public func getBagContent() -> [SelectionProduct] {
        products
    }
}
