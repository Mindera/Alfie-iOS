import Foundation
import Model

public protocol WishlistViewModelProtocol2: ObservableObject {
    var products: [SelectionProduct] { get }
    var hasNavigationSeparator: Bool { get }

    func viewDidAppear()
    func didSelectDelete(for product: SelectionProduct)
    func didTapAddToBag(for product: SelectionProduct)
    func didTapMyAccount()
    func productCardViewModel(for product: SelectionProduct) -> VerticalProductCardViewModel
}
