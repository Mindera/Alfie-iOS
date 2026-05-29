import Foundation
import Model

public final class MockWishlistService: WishlistServiceProtocol {
    private var products: [SelectedProduct]

    public init(products: [SelectedProduct] = []) {
        self.products = products
    }

    public func addProduct(_ product: SelectedProduct) async {
        guard !products.contains(where: { $0.id == product.id }) else { return }

        products.append(product)
    }

    public func removeProduct(withId productId: String) async {
        products = products.filter { $0.product.id != productId }
    }

    public func getWishlistContent() async -> [SelectedProduct] {
        products
    }
}
