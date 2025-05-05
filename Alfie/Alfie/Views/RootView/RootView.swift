import Model
import SharedUI
import SwiftUI

// swiftlint:disable:next generic_type_name
struct RootView<StartupScreenProvider: AppStartupServiceProtocol>: View {
    @StateObject private var startupScreenProvider: StartupScreenProvider
    private let configurationService: ConfigurationServiceProtocol
    private let coordinator: TabCoordinator

    init(
        coordinator: TabCoordinator,
        startupScreenProvider: StartupScreenProvider,
        configurationService: ConfigurationServiceProtocol
    ) {
        _startupScreenProvider = StateObject(wrappedValue: startupScreenProvider)
        self.coordinator = coordinator
        self.configurationService = configurationService
    }

    var body: some View {
        view(for: startupScreenProvider.currentScreen)
            .animation(.emphasized, value: startupScreenProvider.currentScreen)
            .environmentObject(coordinator)
    }
}

// MARK: AppStartupScreen Corresponding View

extension RootView {
    @ViewBuilder
    private func view(for screen: AppStartupScreen) -> some View {
        switch screen {
        case .loading:
            ThemedLoaderView(labelHidden: true, labelTitle: L10n.Loading.title)
                .transition(.opacity)

        case .error:
            Text("Error!") // TODO: Replace with actual error screen

        case .forceUpdate:
            if let configuration = configurationService.forceAppUpdateInfo {
                ForceAppUpdateView(configuration: configuration)
            }

        case .landing:
            TabBarView(configurationService: configurationService)
                .transition(.opacity)
        }
    }
}
