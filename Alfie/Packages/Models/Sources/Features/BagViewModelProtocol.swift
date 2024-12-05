import Foundation

public protocol BagViewModelProtocol: ToolbarModifierContainerViewModelProtocol, ObservableObject {
    var products: [Product] { get }

    func viewDidAppear()
    func didSelectDelete(for productId: String)
}
