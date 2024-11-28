import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ product: SelectionProduct)
    func removeProduct(_ productId: String)
    func getBagContent() -> [SelectionProduct]
}
