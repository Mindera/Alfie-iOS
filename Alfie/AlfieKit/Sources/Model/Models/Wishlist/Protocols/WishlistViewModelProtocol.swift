import Foundation

public protocol WishlistViewModelProtocol: ObservableObject {
    var state: ViewState<[SelectedProduct], Never> { get }
    var hasNavigationSeparator: Bool { get }

    func viewDidAppear()
    func didTapProduct(_ selectedProduct: SelectedProduct)
    func didSelectDelete(for selectedProduct: SelectedProduct)
    func didTapAddToBag(for selectedProduct: SelectedProduct)
}
