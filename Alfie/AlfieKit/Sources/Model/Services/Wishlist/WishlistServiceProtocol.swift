import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ product: SelectedProduct) async
    func removeProduct(withId productId: String) async
    func getWishlistContent() async -> [SelectedProduct]
}
