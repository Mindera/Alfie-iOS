import AlicerceLogging
import Combine
import CombineSchedulers
import Foundation
import Model

public final class DeepLinkHandler: DeepLinkHandlerProtocol {
    private let configurationService: ConfigurationServiceProtocol
    private let log: Logger
    private var pendingLinks: [DeepLink] = []
    private var subscriptions = Set<AnyCancellable>()
    @Published public var isReadyToHandleLinks = false
    private let navigate: (DeepLink.LinkType) -> Void

    public init(
        configurationService: ConfigurationServiceProtocol,
        log: Logger,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        navigate: @escaping (DeepLink.LinkType) -> Void
    ) {
        self.configurationService = configurationService
        self.log = log
        self.navigate = navigate

        $isReadyToHandleLinks
            .filter { $0 }
            .receive(on: scheduler)
            .sink { [weak self] _ in self?.handlePendingLinks() }
            .store(in: &subscriptions)
    }

    // MARK: - DeepLinkHandlerProtocol

    public func canHandleDeepLink(_ deepLink: DeepLink) -> Bool {
        // Check if this link is for a configuration dependent feature
        if let featureKey = deepLink.type.configurationKey() {
            return configurationService.isFeatureEnabled(featureKey)
        }

        // Otherwise always return true as for now we only have this one handler,
        // if more are added in the future, adjust the returned value by link type
        return true
    }

    public func updatePendingDeepLink(_ deepLink: DeepLink) {
        pendingLinks.append(deepLink)
    }

    public func handleDeepLink(_ deepLink: DeepLink) {
        guard canHandleDeepLink(deepLink) else {
            log.warning("Cannot handle deeplink \(deepLink), ignoring")
            return
        }

        guard isReadyToHandleLinks else {
            log.info("App is not yet ready to handle deeplink \(deepLink), adding it to pending list")
            pendingLinks.append(deepLink)
            return
        }

        navigate(deepLink.type)
    }

    // MARK: - Private

    private func handlePendingLinks() {
        guard !pendingLinks.isEmpty else {
            return
        }

        let pendingLink = pendingLinks.removeFirst()
        log.debug("App is ready to handle deeplinks, handle pending deeplink \(pendingLinks)")
        handleDeepLink(pendingLink)

        if !pendingLinks.isEmpty {
            handlePendingLinks()
        }
    }
}
