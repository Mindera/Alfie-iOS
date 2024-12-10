import Foundation
import Models

public final class MockWishListService: WishListServiceProtocol {
    private var products: [SelectionProduct] = []

    public init() { }

    public func addProduct(_ product: SelectionProduct) {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
    }

    public func removeProduct(_ productId: String) {
        products = products.filter { $0.id != productId }
    }

    public func getWishListContent() -> [SelectionProduct] {
        products
    }
}
