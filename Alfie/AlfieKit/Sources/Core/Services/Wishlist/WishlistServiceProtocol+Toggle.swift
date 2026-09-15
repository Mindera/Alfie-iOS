import Foundation
import Model

public extension WishlistServiceProtocol {
    func toggleProduct(
        _ product: Product,
        isFavorite: Bool,
        analytics: AlfieAnalyticsTracker
    ) async -> [SelectedProduct] {
        if isFavorite {
            await removeProduct(withId: product.id)
            analytics.trackRemoveFromWishlist(productID: product.id)
        } else {
            await addProduct(SelectedProduct(product: product))
            analytics.trackAddToWishlist(productID: product.id)
        }
        return await getWishlistContent()
    }
}

public extension Array where Element == SelectedProduct {
    func containsProduct(_ product: Product) -> Bool {
        contains { $0.product.id == product.id }
    }
}
