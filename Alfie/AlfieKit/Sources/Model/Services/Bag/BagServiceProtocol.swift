import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ product: SelectedProduct) async
    func removeProduct(_ product: SelectedProduct) async
    func getBagContent() async -> [SelectedProduct]
}
