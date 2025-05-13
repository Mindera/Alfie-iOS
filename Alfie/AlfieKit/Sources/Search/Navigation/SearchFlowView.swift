import SharedUI
import SwiftUI

public struct SearchFlowView: View {
    @ObservedObject var viewModel: SearchFlowViewModel
    @Namespace private var animation

    public init(viewModel: SearchFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.path) {
                SearchView2(
                    viewModel: viewModel.makeSearchModel(),
                    transition: .matchedGeometryEffect(
                        id: Constants.searchBarGeometryID,
                        namespace: animation
                    )
                )
                .navigationDestination(for: SearchRoute.self) { route in
                    route.destination(
                        searchViewModel: viewModel.makeSearchModel,
                        transition: .matchedGeometryEffect(
                            id: Constants.searchBarGeometryID,
                            namespace: animation
                        ),
                        intentViewBuilder: viewModel.intentViewBuilder
                    )
                }
            }
        }
    }

    private enum Constants {
        static let searchBarGeometryID = "SearchBar"
    }
}
