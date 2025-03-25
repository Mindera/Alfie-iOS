import Combine
import Foundation
import Models
import OrderedCollections

enum AppStartupScreen {
    case loading
    case forceUpdate
    case error
    case landing
}

protocol AppStartupServiceProtocol: ObservableObject {
    var currentScreen: AppStartupScreen { get }
}

final class AppStartupService: AppStartupServiceProtocol {
    private let configurationService: ConfigurationServiceProtocol

    @Published private(set) var currentScreen: AppStartupScreen = .loading
    // CurrentValueSubject because if using @Published, the publisher will emit a new value a bit before the property is updated, leading to some nasty bugs on appStartupScreenCondition
    private var isLoading: CurrentValueSubject<Bool, Never> = .init(true)
    private var didFindError: CurrentValueSubject<Bool, Never> = .init(false)
    private var subscriptions = Set<AnyCancellable>()
    private var appStartupScreenCondition: OrderedDictionary<AppStartupScreen, Bool> {
        [
            .loading: self.isLoading.value,
            .error: self.didFindError.value,
            .forceUpdate: self.configurationService.isForceAppUpdateAvailable,
            .landing: true,
        ]
    }

    private var prioritisedScreen: AppStartupScreen {
        appStartupScreenCondition.first { $0.value }?.key ?? .error
    }

    init(configurationService: ConfigurationServiceProtocol, startupCompletionDelay: CGFloat = 2) {
        self.configurationService = configurationService
        setupSubscriptions()
        WebViewPreload.preloadWebView()
        DispatchQueue.main.asyncAfter(deadline: .now() + startupCompletionDelay) {
            self.isLoading.send(false)
        }
    }

    private func setupSubscriptions() {
        Publishers.Merge(didFindError, isLoading)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.currentScreen = self.prioritisedScreen
            }
            .store(in: &subscriptions)
    }
}
