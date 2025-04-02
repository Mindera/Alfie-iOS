import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    var products: [BagProduct] { get }

    func didSelectDelete(for selectedProduct: BagProduct)
    func productCardViewModel(for selectedProduct: BagProduct) -> HorizontalProductCardViewModel
}
