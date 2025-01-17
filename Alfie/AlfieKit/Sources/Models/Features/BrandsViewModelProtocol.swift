import Combine
import Foundation
import OrderedCollections

public protocol BrandsViewModelProtocol: ObservableObject {
    var state: ViewState<OrderedDictionary<String, [Brand]>, BrandsViewErrorType> { get }
    var sectionTitles: OrderedSet<String> { get }
    var searchText: String { get set }
    var indexVisibilityPublisher: AnyPublisher<Bool, Never> { get }

    func viewDidAppear()
    func brands(for section: String) -> [Brand]
    func searchFocusDidChange(isFocused: Bool)
}

public enum BrandsViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case noResults
}
