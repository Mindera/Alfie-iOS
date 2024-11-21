import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ product: Product)
    func removeProduct(_ productId: String)
    func getBagContent() -> [Product]
}
