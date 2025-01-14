import Foundation

public protocol WishlistViewModelProtocol: ObservableObject {
    var products: [SelectionProduct] { get }

    func viewDidAppear()
    func didSelectDelete(for product: SelectionProduct)
    func didTapAddToBag(for product: SelectionProduct)
    func productCardViewModel(for product: SelectionProduct) -> VerticalProductCardViewModel
}
