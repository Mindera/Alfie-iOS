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

    @discardableResult
    public func removeProduct(withId productId: String) async -> WishlistRemoval? {
        let removal = WishlistRemoval(productId: productId, from: products)
        products = products.filter { $0.product.id != productId }
        return removal
    }

    public func restore(_ removal: WishlistRemoval) async {
        products = removal.restored(into: products)
    }

    public func getWishlistContent() async -> [SelectedProduct] {
        products
    }
}
