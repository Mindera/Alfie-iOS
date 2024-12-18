import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ product: SelectionProduct)
    func removeProduct(_ productId: String)
    func getWishlistContent() -> [SelectionProduct]
}
