import Foundation

public protocol WishListServiceProtocol {
    func addProduct(_ product: SelectionProduct)
    func removeProduct(_ productId: String)
    func getWishListContent() -> [SelectionProduct]
}
