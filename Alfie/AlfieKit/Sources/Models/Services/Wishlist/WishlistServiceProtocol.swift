import Combine
import Foundation

public protocol WishlistServiceProtocol {
    var productsPublisher: AnyPublisher<[WishlistProduct], Never> { get }

    func addProduct(_ wishlistProduct: WishlistProduct)
    func removeProduct(_ wishlistProduct: WishlistProduct)
    func removeProductVariants(_ wishlistProduct: WishlistProduct)
    func containsProduct(_ wishlistProduct: WishlistProduct) -> Bool
}
