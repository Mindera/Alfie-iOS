import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ bagProduct: BagProduct)
    func removeProduct(_ bagProduct: BagProduct)
    func getBagContent() -> [BagProduct]
}
