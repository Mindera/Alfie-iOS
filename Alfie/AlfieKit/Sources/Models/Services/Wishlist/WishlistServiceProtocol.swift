import Foundation

public protocol WishlistServiceProtocol {
    func addProduct(_ wishlistProduct: WishlistProduct)
    func removeProduct(_ wishlistProduct: WishlistProduct)
    func removeProductVariants(_ wishlistProduct: WishlistProduct)
    func getWishlistContent() -> [WishlistProduct]
}
