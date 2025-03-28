import Models

public class MockBagViewModel: BagViewModelProtocol {
    public var products: [SelectedProduct]

    public init(products: [SelectedProduct] = []) {
        self.products = products
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidSelectDeleteCalled: ((SelectedProduct) -> Void)?
    public func didSelectDelete(for selectedProduct: SelectedProduct) {
        onDidSelectDeleteCalled?(selectedProduct)
    }

    public var onProductCardViewModelCalled: ((SelectedProduct) -> HorizontalProductCardViewModel)?
    public func productCardViewModel(for selectedProduct: SelectedProduct) -> HorizontalProductCardViewModel {
        onProductCardViewModelCalled?(selectedProduct) ?? .init(
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
