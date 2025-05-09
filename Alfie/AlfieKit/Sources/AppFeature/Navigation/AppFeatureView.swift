import Model
import SharedUI
import SwiftUI

public struct AppFeatureView<ScreenProvider: AppStartupServiceProtocol>: View {
    @StateObject private var screenProvider: ScreenProvider
    private let serviceProvider: ServiceProviderProtocol
    private let configurationService: ConfigurationServiceProtocol

    public init(
        serviceProvider: ServiceProviderProtocol,
        screenProvider: ScreenProvider,
        configurationService: ConfigurationServiceProtocol
    ) {
        _screenProvider = StateObject(wrappedValue: screenProvider)
        self.serviceProvider = serviceProvider
        self.configurationService = configurationService
    }

    public var body: some View {
        view(for: screenProvider.currentScreen)
            .animation(.emphasized, value: screenProvider.currentScreen)
    }

    private func makeRootTabViewModel() -> RootTabViewModel {
        var tabs: [Model.Tab] = [.home, .shop, .bag]

        if serviceProvider.configurationService.isFeatureEnabled(.wishlist) {
            tabs.insert(.wishlist, at: 2)
        }

        return RootTabViewModel(
            tabs: tabs,
            initialTab: .home,
            serviceProvider: serviceProvider
        )
    }
}

// MARK: AppStartupScreen Corresponding View

extension AppFeatureView {
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
            AppFeature.RootTabView(viewModel: makeRootTabViewModel())
                .transition(.opacity)
        }
    }
}
