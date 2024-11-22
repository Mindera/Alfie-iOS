import Models

public class MockBagViewModel: BagViewModelProtocol {
    public var products: [Product]

    public init(products: [Product] = []) {
        self.products = products
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public func didSelectDelete(for productId: String) {}
}
