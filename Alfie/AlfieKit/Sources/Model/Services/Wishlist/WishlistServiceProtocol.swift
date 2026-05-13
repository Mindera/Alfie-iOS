import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ product: SelectedProduct)
    func removeProduct(withId productId: String)
    func getWishlistContent() -> [SelectedProduct]
}
