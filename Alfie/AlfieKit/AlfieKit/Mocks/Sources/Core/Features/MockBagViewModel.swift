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

    public var onDidSelectDeleteCalled: ((SelectionProduct) -> Void)?
    public func didSelectDelete(for product: SelectionProduct) {
        onDidSelectDeleteCalled?(product)
    }

    public var onProductCardViewModelCalled: ((SelectionProduct) -> HorizontalProductCardViewModel)?
    public func productCardViewModel(for product: SelectionProduct) -> HorizontalProductCardViewModel {
        onProductCardViewModelCalled?(product) ?? .init(
            image: nil,
            designer: "Yves Saint Laurent",
            name: "Rouge Pur Couture",
            colorTitle: "Color:",
            color: "104",
            sizeTitle: "Size:",
            size: "No size",
            priceType: .default(price: "50€")
        )
    }
}
