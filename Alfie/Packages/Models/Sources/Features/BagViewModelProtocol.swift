import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    var products: [Product] { get }

    func viewDidAppear()
    func didSelectDelete(for productId: String)
}
