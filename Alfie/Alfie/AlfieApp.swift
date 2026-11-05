import AppFeature
import Core
import DeepLink
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
    @State private var appFeatureViewModel: AppFeatureViewModel?

    init() {
        try? FontManager.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.isRunningTests {
                EmptyView()
            } else if let viewModel = appFeatureViewModel {
                AppFeatureView(viewModel: viewModel)
                    .onAppear {
                        setupDeepLinkHandlers(viewModel: viewModel)
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
            } else {
                Color.clear
                    .onAppear {
                        // Lazy initialize once appDelegate is ready
                        appFeatureViewModel = AppFeatureViewModel(
                            serviceProvider: appDelegate.serviceProvider,
                            log: log
                        )
                    }
            }
        }
    }

    // MARK: - Deep Linking

    private func setupDeepLinkHandlers(viewModel: AppFeatureViewModel) {
        let deepLinkHandler = DeepLinkHandler(
            configurationService: appDelegate.serviceProvider.configurationService,
            log: log
        ) {
            viewModel.navigate(for: $0)
        }
        appDelegate.serviceProvider.deepLinkService.update(handlers: [deepLinkHandler])
    }

    private func open(url: URL) {
        appDelegate.serviceProvider.deepLinkService.openUrls([url])
    }
}
