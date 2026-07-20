import Model
import SharedUI
import SwiftUI

public struct AppFeatureView<ViewModel: AppFeatureViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        view(for: viewModel.currentScreen)
            .animation(.emphasized, value: viewModel.currentScreen)
    }
}

// MARK: AppStartupScreen Corresponding View

extension AppFeatureView {
    @ViewBuilder
    private func view(for screen: AppStartupScreen) -> some View {
        switch screen {
        case .loading:
            SplashView()
                .transition(.opacity)

        case .error:
            Text("Error!") // TODO: Replace with actual error screen

        case .forceUpdate:
            if let configuration = viewModel.appUpdateInfoConfiguration {
                ForceAppUpdateView(configuration: configuration)
            }

        case .landing:
            AppFeature.RootTabView(viewModel: viewModel.rootTabViewModel)
                .transition(.opacity)
        }
    }
}
