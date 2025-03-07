import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    var products: [SelectedProduct] { get }

    func viewDidAppear()
    func didSelectDelete(for selectedProduct: SelectedProduct)
    func productCardViewModel(for selectedProduct: SelectedProduct) -> HorizontalProductCardViewModel
}
