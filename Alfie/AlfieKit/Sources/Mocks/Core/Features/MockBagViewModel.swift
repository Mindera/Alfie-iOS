import Models

public class MockBagViewModel: BagViewModelProtocol {
    public var products: [BagProduct]

    public init(products: [BagProduct] = []) {
        self.products = products
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidSelectDeleteCalled: ((BagProduct) -> Void)?
    public func didSelectDelete(for selectedProduct: BagProduct) {
        onDidSelectDeleteCalled?(selectedProduct)
    }

    public var onProductCardViewModelCalled: ((BagProduct) -> HorizontalProductCardViewModel)?
    public func productCardViewModel(for selectedProduct: BagProduct) -> HorizontalProductCardViewModel {
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
