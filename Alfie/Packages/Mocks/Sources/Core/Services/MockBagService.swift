import Foundation
import Models

public final class MockBagService: BagServiceProtocol {
    private var products: [Product] = []

    public init() { }

    public func addProduct(_ product: Product) {
        guard !products.contains(
            where: {
                $0.defaultVariant.colour?.id == product.defaultVariant.colour?.id &&
                $0.defaultVariant.size?.id == product.defaultVariant.size?.id
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

    public func getBagContent() -> [Product] {
        products
    }
}