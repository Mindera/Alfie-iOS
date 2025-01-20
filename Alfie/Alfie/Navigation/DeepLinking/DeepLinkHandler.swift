import Combine
import Foundation
import Models
import Navigation

final class DeepLinkHandler: DeepLinkHandlerProtocol {
    private let coordinator: TabCoordinatorProtocol
    private let configurationService: ConfigurationServiceProtocol
    private var pendingLinks: [DeepLink] = []
    private var subscriptions = Set<AnyCancellable>()
    private var isReadyToHandleLinks = false

    init(configurationService: ConfigurationServiceProtocol, coordinator: TabCoordinatorProtocol) {
        self.configurationService = configurationService
        self.coordinator = coordinator

        self.coordinator.navigationAvailability
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReadyToHandleLinks in
                self?.isReadyToHandleLinks = isReadyToHandleLinks
                if isReadyToHandleLinks {
                    self?.handlePendingLinks()
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - DeepLinkHandlerProtocol

    func canHandleDeepLink(_ deepLink: DeepLink) -> Bool {
        // Check if this link is for a configuration dependent feature
        if let featureKey = deepLink.type.configurationKey() {
            return configurationService.isFeatureEnabled(featureKey)
        }

        // Otherwise always return true as for now we only have this one handler,
        // if more are added in the future, adjust the returned value by link type
        return true
    }

    func handleDeepLink(_ deepLink: DeepLink) {
        guard canHandleDeepLink(deepLink) else {
            log.debug("Cannot handle deeplink \(deepLink), ignoring")
            return
        }

        guard isReadyToHandleLinks else {
            log.info("App is not yet ready to handle deeplink \(deepLink), adding it to pending list")
            pendingLinks.append(deepLink)
            return
        }

        var target: Screen?
        switch deepLink.type {
        case .home:
            target = Screen.tab(.home())

        case .shop(let route):
            switch route {
            case ThemedURL.brands.path:
                target = Screen.tab(.shop(tab: .brands))

            case ThemedURL.services.path:
                target = Screen.tab(.shop(tab: .services))

            default:
                target = Screen.tab(.shop(tab: .categories))
            }

        case .bag:
            target = Screen.tab(.bag)

        case .wishlist:
            target = Screen.wishlist

        case .account:
            target = Screen.account

        case .productList(let paths, let searchText, let urlQueryParameters):
            let configuration = ProductListingScreenConfiguration(
                category: paths,
                searchText: searchText,
                urlQueryParameters: urlQueryParameters,
                mode: .listing
            )
            target = Screen.productListing(configuration: configuration)

        case .productDetail(let productId, _, _, _):
            // TODO: currently the API does not support fetching a product by the StyleNumber (that is parsed from the URL), just by ProductID, so all requests will return "not found"
            target = Screen.productDetails(.id(productId))

        case .webView(let url):
            target = Screen.webView(url: url, title: "")

        case .unknown:
            return
        }

        if let target {
            log.debug("Handling deeplink \(deepLink) by navigating to \(target)")
            coordinator.navigate(to: target)
        }
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
