import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ product: SelectionProduct)
    func removeProduct(_ product: SelectionProduct)
    func getBagContent() -> [SelectionProduct]
}
