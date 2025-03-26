import Foundation

public protocol WishlistViewModelProtocol: ObservableObject {
    var products: [WishlistProduct] { get }

    func viewDidAppear()
    func didSelectDelete(for wishlistProduct: WishlistProduct)
    func productCardViewModel(for wishlistProduct: WishlistProduct) -> VerticalProductCardViewModel
}
