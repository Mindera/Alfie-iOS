import SharedUI
import SwiftUI

public extension SearchRoute {
    @ViewBuilder
    func destination(
        searchViewModel: () -> some SearchViewModelProtocol2,
        transition: SearchBarTransition?,
        intentViewBuilder: @escaping (SearchIntent) -> AnyView
    ) -> some View {
        switch self {
        case .search:
            SearchView2(viewModel: searchViewModel(), transition: transition)

        case .searchIntent(let intent):
            intentViewBuilder(intent)
        }
    }
}
