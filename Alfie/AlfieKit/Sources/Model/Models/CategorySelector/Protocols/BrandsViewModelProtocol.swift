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
    func didTapBrand(_ brand: Brand)
    func searchFocusDidChange(isFocused: Bool)
}

public enum BrandsViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case noResults
    case rateLimited
    case serverError

    public static func from(error: Error) -> BrandsViewErrorType {
        guard let bff = error as? BFFRequestError else { return .generic }
        switch bff.type {
        case .rateLimited: return .rateLimited
        case .serverError: return .serverError
        case .noInternet: return .noInternet
        case .product(.noProduct), .product(.noProducts), .emptyResponse: return .noResults
        case .timeout, .product(.generic), .generic: return .generic
        }
    }
}
