import Foundation

public protocol BagServiceProtocol {
    func addProduct(_ product: Product, selectedVariant: Product.Variant)
    func removeProduct(_ productId: String)
    func getBagContent() -> [Product]
}

