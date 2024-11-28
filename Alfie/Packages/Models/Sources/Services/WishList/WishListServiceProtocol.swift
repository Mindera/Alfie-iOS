import Foundation

public protocol WishListServiceProtocol {
    func addProduct(_ product: SelectionProduct)
    func removeProductWith(colourId: String?, sizeId: String?)
    func getWishListContent() -> [SelectionProduct]
}
