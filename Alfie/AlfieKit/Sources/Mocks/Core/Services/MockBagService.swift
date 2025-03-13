import Combine
import Foundation
import Models

public final class MockBagService: BagServiceProtocol {
    @Published private var products: [BagProduct] = []

    public var productsPublisher: AnyPublisher<[BagProduct], Never> {
        $products.eraseToAnyPublisher()
    }

    public init() { }

    public func addProduct(_ bagProduct: BagProduct) {
        guard !products.contains(where: { $0.id == bagProduct.id }) else { return }

        products.append(bagProduct)
    }

    public func removeProduct(_ bagProduct: BagProduct) {
        products = products.filter { $0.id != bagProduct.id }
    }

    public func containsProduct(_ bagProduct: BagProduct) -> Bool {
        products.contains { $0.id == bagProduct.id }
    }
}
