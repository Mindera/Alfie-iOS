import Combine
import Foundation

public protocol BagServiceProtocol {
    var productsPublisher: AnyPublisher<[BagProduct], Never> { get }

    func addProduct(_ bagProduct: BagProduct)
    func removeProduct(_ bagProduct: BagProduct)
    func containsProduct(_ bagProduct: BagProduct) -> Bool
}
