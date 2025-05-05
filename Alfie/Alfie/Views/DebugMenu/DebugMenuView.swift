import Core
import Model
#if DEBUG
import Mocks
#endif
import SharedUI
import SwiftUI

// MARK: - DebugMenuView

struct DebugMenuView: View {
    @EnvironmentObject var coordinator: Coordinator
    private let serviceProvider: ServiceProviderProtocol

    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }

    var body: some View {
        NavigationStack {
            VStack {
                DemoHelper.demoHeader(title: "Debug Menu")
                    .padding(.vertical, Spacing.space050)
                Spacer()
                List {
                    link(for: .catalogue, text: "Catalogue App")
                    link(for: .deeplinking, text: "Deep Linking")
                    link(for: .appUpdate, text: "Force & Soft Update")
                    link(for: .brazeInfo, text: "Braze Push")
                    #if DEBUG
                    link(for: .featureToggle, text: "Feature Toggle")
                    #endif
                    link(for: .endpoint, text: "Environment")
                }
                .listStyle(.plain)
            }
            .navigationDestination(for: DebugNavigation.self) { destination in
                navigateTo(destination)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ThemedToolbarButton(icon: .close) { coordinator.closeDebugMenu() }
                }
                ToolbarItem(placement: .principal) {
                    ThemedToolbarTitle(style: .logo)
                }
            }
            .modifier(ThemedToolbarModifier())
        }
    }

    private func link(for link: DebugNavigation, text: String) -> some View {
        NavigationLink(value: link) {
            Text.build(theme.font.small.normal(text))
        }
    }

    @ViewBuilder
    private func navigateTo(_ destination: DebugNavigation) -> some View {
        switch destination {
        case .catalogue:
            StyleGuideDemoView()
                .modifier(ContainerDemoViewModifier(embedInScrollView: false))

        case .deeplinking:
            DeepLinkDemoView()
                .modifier(ContainerDemoViewModifier(headerTitle: "Deep Linking"))

        case .appUpdate:
            AppUpdateDemoView(configurationService: serviceProvider.configurationService)
                .modifier(ContainerDemoViewModifier(headerTitle: "Force & Soft Update"))

        case .brazeInfo:
            BrazeDemoView(brazeUserId: BrazeConstants.userID)
                .modifier(ContainerDemoViewModifier(headerTitle: "Braze Push"))

        case .endpoint:
            EndpointSelectionView(
                viewModel: EndpointSelectionViewModel(apiEndpointService: serviceProvider.apiEndpointService)
            )
            .modifier(
                ContainerDemoViewModifier(headerTitle: "Environment", embedInScrollView: false)
            )

        case .featureToggle:
            FeatureToggleView(viewModel: FeatureToggleViewModel(provider: DebugConfigurationProvider.shared))
                .modifier(
                    ContainerDemoViewModifier(headerTitle: L10n.FeatureToggle.title, embedInScrollView: true)
                )
        }
    }

    private enum DebugNavigation: Hashable {
        case catalogue
        case deeplinking
        case appUpdate
        case brazeInfo
        case endpoint
        case featureToggle
    }
}

#if DEBUG
#Preview {
    DebugMenuView(serviceProvider: MockServiceProvider())
}
#endif
