import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ product: SelectedProduct)
    func removeProduct(_ product: SelectedProduct)
    func getBagContent() -> [SelectedProduct]
}
