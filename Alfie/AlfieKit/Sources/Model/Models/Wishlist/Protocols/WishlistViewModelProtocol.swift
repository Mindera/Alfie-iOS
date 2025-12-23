import Foundation

public protocol WishlistViewModelProtocol: ObservableObject {
    var products: [SelectedProduct] { get }
    var hasNavigationSeparator: Bool { get }

    func viewDidAppear()
    func didTapProduct(_ selectedProduct: SelectedProduct)
    func didSelectDelete(for selectedProduct: SelectedProduct)
    func didTapAddToBag(for selectedProduct: SelectedProduct)
    func didTapMyAccount()
    func productCardViewModel(for selectedProduct: SelectedProduct) -> VerticalProductCardViewModel
}
