import Foundation
import Model

public protocol BagViewModelProtocol2: ObservableObject {
    var products: [SelectedProduct] { get }
    var isWishlistEnabled: Bool { get }

    func viewDidAppear()
    func didTapProduct(_ selectedProduct: SelectedProduct)
    func didSelectDelete(for selectedProduct: SelectedProduct)
    func didTapMyAccount()
    func didTapWishlist()
    func productCardViewModel(for selectedProduct: SelectedProduct) -> HorizontalProductCardViewModel
}
