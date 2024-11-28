import Models

public class MockBagViewModel: BagViewModelProtocol {
    public var products: [SelectionProduct]

    public init(products: [SelectionProduct] = []) {
        self.products = products
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidSelectDeleteCalled: ((Product) -> Void)?
    public func didSelectDelete(for product: Product) {
        onDidSelectDeleteCalled?(product)
    }
}
