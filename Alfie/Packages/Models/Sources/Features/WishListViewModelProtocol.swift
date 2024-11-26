import Foundation

public protocol WishListViewModelProtocol: ObservableObject {
    var products: [Product] { get }

    func viewDidAppear()
    func didSelectDelete(for product: Product)
    func didTapAddToBag(for product: Product)
}
