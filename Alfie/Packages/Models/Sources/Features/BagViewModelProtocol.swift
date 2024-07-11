import Foundation

public protocol BagViewModelProtocol: ObservableObject {
    func webViewModel() -> any WebViewModelProtocol
}
