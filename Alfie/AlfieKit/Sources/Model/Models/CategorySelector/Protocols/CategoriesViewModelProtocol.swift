import Combine
import Foundation

public struct CategoriesViewStateModel {
    public let categories: [NavigationItem]
    public let title: String

    public init(categories: [NavigationItem], title: String = "") {
        self.categories = categories
        self.title = title
    }
}

public enum CategoriesViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case noResults
    case rateLimited
    case serverError

    public static func from(error: Error) -> CategoriesViewErrorType {
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

public enum CategoriesNavigationDestination {
    case plp(category: String)
    case web(url: URL, title: String)
    case services
    case brands
    case subCategories(_ subCategories: [NavigationItem], parentCategory: NavigationItem)
}

public protocol CategoriesViewModelProtocol: ObservableObject {
    var openCategoryPublisher: AnyPublisher<CategoriesNavigationDestination, Never> { get }
    var state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> { get }
    var categories: [NavigationItem] { get }
    var title: String { get }
    var shouldShowToolbar: Bool { get }
    /// Whether this screen can pull-to-refresh. Only the root categories screen fetches from the
    /// service; drill-down screens render a static snapshot, so their refresh affordance is hidden.
    var canRefresh: Bool { get }

    func viewDidAppear()
    func refresh() async
    func didSelectCategory(_ category: NavigationItem)
}
