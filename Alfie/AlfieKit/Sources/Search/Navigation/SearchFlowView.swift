import SharedUI
import SwiftUI

public struct SearchFlowView: View {
    @ObservedObject var viewModel: SearchFlowViewModel
    @Namespace private var animation
    private let transition: SearchBarTransition?

    public init(
        viewModel: SearchFlowViewModel,
        transition: SearchBarTransition? = nil
    ) {
        self.viewModel = viewModel
        self.transition = transition
    }

    public var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.path) {
                SearchView2(
                    viewModel: viewModel.makeSearchModel(),
                    transition: transition
                )
                .navigationDestination(for: SearchRoute.self) { route in
                    route.destination(
                        searchViewModel: viewModel.makeSearchModel,
                        transition: transition,
                        intentViewBuilder: viewModel.intentViewBuilder
                    )
                }
            }
        }
    }
}
