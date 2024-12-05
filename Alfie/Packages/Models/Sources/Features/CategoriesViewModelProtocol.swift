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
}

public enum CategoriesNavigationDestination {
    case plp(category: String)
    case web(url: URL, title: String)
    case services
    case brands
    case subCategories(_ subCategories: [NavigationItem], parentCategory: NavigationItem)
}

public protocol CategoriesViewModelProtocol: ToolbarModifierContainerViewModelProtocol, ObservableObject {
    var openCategoryPublisher: AnyPublisher<CategoriesNavigationDestination, Never> { get }
    var state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> { get }
    var categories: [NavigationItem] { get }
    var title: String { get }
    var shouldShowToolbar: Bool { get }

    func viewDidAppear()
    func didSelectCategory(_ category: NavigationItem)
}
