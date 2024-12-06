import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    var products: [SelectionProduct] { get }

    func viewDidAppear()
    func didSelectDelete(for product: SelectionProduct)
    func productCardViewModel(for product: SelectionProduct) -> HorizontalProductCardViewModel
}
