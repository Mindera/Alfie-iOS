import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    var products: [BagProduct] { get }

    func viewDidAppear()
    func didSelectDelete(for selectedProduct: BagProduct)
    func productCardViewModel(for selectedProduct: BagProduct) -> HorizontalProductCardViewModel
}
