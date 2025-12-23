import Model
import SharedUI
import SwiftUI

public extension SearchRoute {
    @ViewBuilder
    func destination(
        searchViewModel: () -> some SearchViewModelProtocol,
        transition: SearchBarTransition?,
        intentViewBuilder: @escaping (SearchIntent) -> AnyView
    ) -> some View {
        switch self {
        case .search:
            SearchView(viewModel: searchViewModel(), transition: transition)

        case .searchIntent(let intent):
            intentViewBuilder(intent)
        }
    }
}
