import Combine
import Core
import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

// MARK: - TabBarView

#if DEBUG
class BagContent: ObservableObject {
    @Published var products: [Product] = []
}
#endif

struct TabBarView: View {
    #if DEBUG
    @StateObject private var bagContent = BagContent()
    #endif
    @EnvironmentObject private var tabCoordinator: TabCoordinator
    private let configurationService: ConfigurationServiceProtocol
    @State private var isShowingAppUpdateAlert = false
    @State private var appUpdateRecommended: AppUpdateInfo?
    private let hapticsService: HapticsServiceProtocol
    private(set) static var size: CGSize = .zero

    init(
        configurationService: ConfigurationServiceProtocol,
        hapticsService: HapticsServiceProtocol = HapticsService.instance
    ) {
        self.configurationService = configurationService
        self.hapticsService = hapticsService
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabCoordinator.activeTab) {
                ForEach($tabCoordinator.tabs, id: \.self) { $tab in
                    tabCoordinator.view(for: tab)
                        .toolbar(tabCoordinator.shouldShowTabBar ? .visible : .hidden, for: .tabBar)
                }
            }
            #if DEBUG
            .environmentObject(bagContent)
            #endif
            .onChange(of: tabCoordinator.activeTab) { _ in
                hapticsService.trigger(.selectionChanged)
            }
            .onReceive(configurationService.providerBecameAvailablePublisher) { _ in
                checkAppUpdateConfiguration()
            }
            .onAppear {
                tabCoordinator.enableNavigation(isActive: true)
                checkAppUpdateConfiguration()
            }
            .alert(
                appUpdateRecommended?.title ?? "",
                isPresented: $isShowingAppUpdateAlert,
                actions: { SoftAppUpdateAlertActionsView(update: appUpdateRecommended) },
                message: { SoftAppUpdateAlertMessageView(update: appUpdateRecommended) }
            )
            .accentColor(Colors.primary.black)
            .padding(.bottom, Spacing.space150)

            if tabCoordinator.shouldShowTabBar {
                CustomTabBarView(tabs: tabCoordinator.tabs, currentTab: $tabCoordinator.activeTab)
                    .writingSize(to: .init(get: {
                        .zero
                    }, set: { size in
                        Self.size = size
                    }))
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - App Update

    private func checkAppUpdateConfiguration() {
        if configurationService.isForceAppUpdateAvailable {
            tabCoordinator.navigate(to: .forceAppUpdate)
            return
        }

        if configurationService.isSoftAppUpdateAvailable {
            appUpdateRecommended = configurationService.softAppUpdateInfo
            if !isShowingAppUpdateAlert {
                isShowingAppUpdateAlert = appUpdateRecommended != nil
            }
        }
    }
}

// MARK: - Tab Items

extension TabScreen {
    var correspondingScreen: Screen {
        // swiftlint:disable vertical_whitespace_between_cases
        switch self {
        case .home:
            Screen.tab(.home())
        case .shop:
            Screen.tab(.shop())
        case .bag:
            Screen.tab(.bag)
        case .wishlist:
            Screen.tab(.wishlist)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#if DEBUG
#Preview {
    VStack {
        let serviceProvider = MockServiceProvider()
        TabBarView(configurationService: serviceProvider.configurationService)
            .environmentObject(
                TabCoordinator(tabs: TabScreen.allCases, activeTab: .home(), serviceProvider: serviceProvider)
            )
    }
}
#endif
