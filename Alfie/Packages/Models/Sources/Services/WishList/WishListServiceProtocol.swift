import Foundation

public protocol WishListServiceProtocol {
    func addProduct(_ product: Product)
    func removeProduct(_ product: Product)
    func getWishListContent() -> [Product]
}
