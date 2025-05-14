import Model

public class MockBagViewModel: BagViewModelProtocol {
    public var products: [SelectedProduct]
    public var isWishlistEnabled: Bool = false

    public init(products: [SelectedProduct] = []) {
        self.products = products
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onDidTapProductCalled: ((SelectedProduct) -> Void)?
    public func didTapProduct(_ selectedProduct: SelectedProduct) {
        onDidTapProductCalled?(selectedProduct)
    }

    public var onDidSelectDeleteCalled: ((SelectedProduct) -> Void)?
    public func didSelectDelete(for selectedProduct: SelectedProduct) {
        onDidSelectDeleteCalled?(selectedProduct)
    }

    public var onDidTapMyAccountCalled: (() -> Void)?
    public func didTapMyAccount() {
        onDidTapMyAccountCalled?()
    }

    public var onDidTapWishlistCalled: (() -> Void)?
    public func didTapWishlist() {
        onDidTapWishlistCalled?()
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
