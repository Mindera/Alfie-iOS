import AppFeature
import Core
import Model
import SharedUI
import SwiftUI
import UIKit
import Utils

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var sessionID = UUID()
}

@main
struct AlfieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState = AppState.shared

    init() {
        try? FontManager.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.isRunningTests {
                EmptyView()
            } else {
                AppFeatureView(
                    serviceProvider: appDelegate.serviceProvider,
                    screenProvider: AppStartupService(
                        configurationService: appDelegate.serviceProvider.configurationService
                    ),
                    configurationService: appDelegate.serviceProvider.configurationService
                )
//                RootView(
//                    coordinator: appDelegate.tabCoordinator,
//                    startupScreenProvider: AppStartupService(
//                        configurationService: appDelegate.serviceProvider.configurationService
//                    ),
//                    configurationService: appDelegate.serviceProvider.configurationService
//                )
                .onAppear {
                    setupDeepLinkHandlers()
                }
                .onOpenURL { url in
                    open(url: url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    userActivity.webpageURL.map {
                        open(url: $0)
                    }
                }
                .id(appState.sessionID) // So that the view can be recreated / rebooted
            }
        }
    }

    // MARK: - Deep Linking

    private func setupDeepLinkHandlers() {
        let deepLinkHandler = DeepLinkHandler(
            configurationService: appDelegate.serviceProvider.configurationService,
            coordinator: appDelegate.tabCoordinator
        )
        appDelegate.serviceProvider.deepLinkService.update(handlers: [deepLinkHandler])
    }

    private func open(url: URL) {
        appDelegate.serviceProvider.deepLinkService.openUrls([url])
    }
}
