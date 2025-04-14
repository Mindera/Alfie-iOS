import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ product: SelectedProduct)
    func removeProduct(_ product: SelectedProduct)
    func getWishlistContent() -> [SelectedProduct]
}
