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

public enum CategoriesViewErrorType: Error, CaseIterable, FailureKindRepresentable {
    case generic
    case noConnection
    case noResults
    case rateLimited
    case serverError

    public static func from(error: Error) -> CategoriesViewErrorType {
        from(error: error, notFound: .noResults)
    }
}

public protocol CategoriesViewModelProtocol: ObservableObject {
    var state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> { get }
    var categories: [NavigationItem] { get }
    var title: String { get }
    var shouldShowToolbar: Bool { get }
    /// Whether this screen can pull-to-refresh. Only the root categories screen fetches from the
    /// service; drill-down screens render a static snapshot, so their refresh affordance is hidden.
    var canRefresh: Bool { get }
    /// Root (level 1) vs drill-down (level 2/3) — drives the larger root menu typography per Figma.
    var isRoot: Bool { get }

    func viewDidAppear()
    func refresh() async
    func retry() async
    func didSelectCategory(_ category: NavigationItem)
}
