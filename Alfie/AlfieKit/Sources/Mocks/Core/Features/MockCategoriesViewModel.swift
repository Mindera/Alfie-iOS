import Combine
import Foundation
import Model

public class MockCategoriesViewModel: CategoriesViewModelProtocol {
    public var state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> = .loading
    public var categories: [NavigationItem]
    public var title = ""
    public var shouldShowToolbar = false
    public var canRefresh = true

    public init(state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> = .loading,
                categories: [NavigationItem] = []) {
        self.state = state
        self.categories = categories
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public func refresh() async {}

    public func retry() async {}

    public var onDidSelectCategoryCalled: ((NavigationItem) -> Void)?
    public func didSelectCategory(_ category: NavigationItem) {
        onDidSelectCategoryCalled?(category)
    }
}
