import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ product: SelectedProduct) async
    func removeProduct(withId productId: String) async
    func restoreProduct(_ product: SelectedProduct, at position: Int) async
    func getWishlistContent() async -> [SelectedProduct]
}
