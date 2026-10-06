import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ product: SelectedProduct) async
    @discardableResult
    func removeProduct(withId productId: String) async -> WishlistRemoval?
    func restore(_ removal: WishlistRemoval) async
    func getWishlistContent() async -> [SelectedProduct]
}
