import SwiftUI

public struct MyAccountFlowView: View {
    @ObservedObject var viewModel: MyAccountFlowViewModel

    public init(viewModel: MyAccountFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.path) {
                AccountView(viewModel: viewModel.makeAccountViewModel())
                    .navigationDestination(for: MyAccountRoute.self) { route in
                        route.destination(
                            accountViewModel: viewModel.makeAccountViewModel,
                            intentViewBuilder: viewModel.intentViewBuilder
                        )
                    }
            }
        }
    }
}
