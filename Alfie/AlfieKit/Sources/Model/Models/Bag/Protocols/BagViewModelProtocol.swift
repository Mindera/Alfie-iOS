import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    var products: [SelectedProduct] { get }
    var isWishlistEnabled: Bool { get }

    func viewDidAppear()
    func didTapProduct(_ selectedProduct: SelectedProduct)
    func didSelectDelete(for selectedProduct: SelectedProduct)
    func didTapMyAccount()
    func didTapWishlist()
    func productCardViewModel(for selectedProduct: SelectedProduct) -> HorizontalProductCardViewModel
}
