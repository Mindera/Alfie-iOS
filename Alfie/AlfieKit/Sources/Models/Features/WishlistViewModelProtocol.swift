import Foundation

public protocol WishlistViewModelProtocol: ObservableObject {
    var products: [SelectedProduct] { get }

    func viewDidAppear()
    func didSelectDelete(for selectedProduct: SelectedProduct)
    func didTapAddToBag(for selectedProduct: SelectedProduct)
    func productCardViewModel(for selectedProduct: SelectedProduct) -> VerticalProductCardViewModel
}
