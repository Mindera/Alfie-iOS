import Combine
import Foundation
import Model
import OrderedCollections
import Utils

public final class AppFeatureViewModel: AppFeatureViewModelProtocol {
    private let configurationService: ConfigurationServiceProtocol

    @Published public private(set) var currentScreen: AppStartupScreen = .loading
    public let rootTabViewModel: RootTabViewModel
    public let appUpdateInfoConfiguration: AppUpdateInfo?
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

    public init(
        serviceProvider: ServiceProviderProtocol,
        startupCompletionDelay: CGFloat = 2
    ) {
        self.configurationService = serviceProvider.configurationService

        var tabs: [Model.Tab] = [.home, .shop, .bag]

        if serviceProvider.configurationService.isFeatureEnabled(.wishlist) {
            tabs.insert(.wishlist, at: 2)
        }

        self.rootTabViewModel = RootTabViewModel(
            tabs: tabs,
            initialTab: .home,
            serviceProvider: serviceProvider
        )

        self.appUpdateInfoConfiguration = serviceProvider.configurationService.forceAppUpdateInfo

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
