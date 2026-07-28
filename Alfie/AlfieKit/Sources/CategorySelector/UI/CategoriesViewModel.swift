import AlicerceLogging
import Combine
import Core
import Foundation
import Model
import Utils

public final class CategoriesViewModel: CategoriesViewModelProtocol {
    private enum Constants {
        static let placeholderTitleLowerBound: Int = 30
        static let placeholderTitleUpperBound: Int = 50
        static let placeholderItemCount: Int = 10
    }

    // Special categories that open specific native screens instead of a webview / PLP / sub-categories screen
    private enum SpecialCategories: String, CaseIterable {
        case services = "/store-services"
        case brands = "/brands"

        var destination: CategoriesNavigationDestination {
            // swiftlint:disable vertical_whitespace_between_cases
            switch self {
            case .services:
                .services
            case .brands:
                .brands
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }

        var themedUrl: ThemedURL {
            // swiftlint:disable vertical_whitespace_between_cases
            switch self {
            case .services:
                .services
            case .brands:
                .brands
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }

    private let navigationService: NavigationServiceProtocol?
    private let log: Logger
    // True while a fetch is in flight, so concurrent loads/refreshes don't race (last-writer-wins).
    private var isFetching = false
    private let openCategorySubject: PassthroughSubject<CategoriesNavigationDestination, Never> = .init()
    private lazy var placeholders: [NavigationItem] = {
        (0..<Constants.placeholderItemCount).map { _ in
            .init(
                id: UUID().uuidString,
                type: .page,
                title: String(
                    repeating: " ",
                    count: .random(in: Constants.placeholderTitleLowerBound...Constants.placeholderTitleUpperBound)
                ),
                url: nil,
                media: nil,
                items: nil,
                attributes: nil
            )
        }
    }()

    @Published public private(set) var state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> = .loading
    public lazy var openCategoryPublisher = openCategorySubject.eraseToAnyPublisher()

    public var categories: [NavigationItem] {
        if state.isLoading {
            return placeholders
        }

        guard case .success(let model) = state else {
            return []
        }

        return model.categories
    }

    public var title: String {
        guard case .success(let model) = state else {
            return ""
        }

        return model.title
    }

    public private(set) var shouldShowToolbar: Bool
    // Only the root screen holds a navigationService; drill-down screens are static snapshots.
    public var canRefresh: Bool { navigationService != nil }
    /// A bool controling if local tab navigation should be ignored (i.e., shop links like Brands and Service) so that they can be handled by the parent shop view
    private let ignoreLocalNavigation: Bool
    private let navigate: (CategorySelectorRoute) -> Void

    init(
        navigationService: NavigationServiceProtocol,
        log: Logger,
        showToolbar: Bool = false,
        ignoreLocalNavigation: Bool,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.navigationService = navigationService
        self.log = log
        self.shouldShowToolbar = showToolbar
        self.ignoreLocalNavigation = ignoreLocalNavigation
        self.navigate = navigate
    }

    init(
        log: Logger,
        categories: [NavigationItem],
        title: String,
        showToolbar: Bool = true,
        ignoreLocalNavigation: Bool,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.log = log
        self.navigationService = nil
        self.state = .success(.init(categories: categories, title: title))
        self.shouldShowToolbar = showToolbar
        self.ignoreLocalNavigation = ignoreLocalNavigation
        self.navigate = navigate
    }

    public func viewDidAppear() {
        Task {
            await loadItems()
        }
    }

    public func didSelectCategory(_ category: NavigationItem) {
        // A category with sub-categories drills in — even if its url matches a SpecialCategory, the
        // sub-menu takes precedence so the children remain reachable.
        if category.hasSubCategories, let subCategories = category.items {
            openCategorySubject.send(.subCategories(subCategories, parentCategory: category))
            navigate(.subCategories(subCategories: subCategories, parent: category))
            return
        }

        // Special categories (as leaves) open their native screen.
        if let specialCategory = SpecialCategories.allCases.first(
            where: { $0.rawValue == category.url?.lowercased() }
        ) {
            openCategorySubject.send(specialCategory.destination)
            guard !ignoreLocalNavigation, let url = specialCategory.themedUrl.internalUrl else { return }
            ExternalAppLauncher.open(url: url)
            return
        }

        guard let categoryUrl = category.url else {
            log.error("Error building URL for category from navigation item: \(category)")
            state = .error(.generic)
            return
        }

        switch category.type {
        case .listing:
            let sanitizedCategoryUrl = categoryUrl.deletingPrefix("/")
            openCategorySubject.send(.plp(category: sanitizedCategoryUrl))
            navigate(
                .productListing(
                    .productListing(
                        .init(
                            category: sanitizedCategoryUrl,
                            searchText: nil,
                            urlQueryParameters: nil,
                            mode: .listing
                        )
                    )
                )
            )

        case .externalHttp,
             .home, // swiftlint:disable:this indentation_width
             .page,
             .product,
             .search,
             .account,
             .wishlist:
            // Temporarily open a webview with this category, until we have all screens
            guard let url = webViewURL(from: categoryUrl) else {
                log.error("Error building web URL for category from navigation item: \(category)")
                state = .error(.generic)
                return
            }
            openCategorySubject.send(.web(url: url, title: category.title))
            navigate(.web(url: url, title: category.title))
        }
    }

    // Shopify returns absolute page/blog urls — open those verbatim so the webview hits the real
    // host. A relative path resolves against our own web host (the pre-BFF behavior).
    private func webViewURL(from categoryUrl: String) -> URL? {
        if let absolute = URL(string: categoryUrl), absolute.scheme != nil, absolute.host != nil {
            return absolute
        }
        guard var url = URL(string: "https://\(ThemedURL.hostWithPortComponent)") else { return nil }
        categoryUrl.components(separatedBy: "/").filter { !$0.isEmpty }.forEach { url = url.appending(component: $0) }
        return url
    }

    @MainActor
    public func refresh() async {
        // Pull-to-refresh keeps its own spinner (no flip to `.loading`) and keeps the current list on
        // screen. The menu is never cached, so this always re-fetches. If a fetch is already in
        // flight (e.g. the initial load) `fetchNavigationItems` no-ops, so the two can't race.
        await fetchNavigationItems()
    }

    @MainActor
    public func retry() async {
        // Recovery from the error screen: unlike pull-to-refresh, show the loading state for feedback.
        guard !isFetching else { return }
        state = .loading
        await fetchNavigationItems()
    }

    // MARK: - Private

    @MainActor
    private func loadItems() async {
        guard !state.isSuccess, !isFetching else {
            return
        }

        if !state.isLoading {
            state = .loading
        }

        await fetchNavigationItems()
    }

    @MainActor
    private func fetchNavigationItems() async {
        // Only one fetch runs at a time — a pull-to-refresh during the initial load (or vice versa)
        // is ignored, so a slower fetch can't overwrite a newer result.
        guard let navigationService, !isFetching else {
            return
        }
        isFetching = true
        defer { isFetching = false }

        let navigationItems: [NavigationItem]

        do {
            navigationItems = try await navigationService.getNavigationItems(for: .shop)
        } catch is CancellationError {
            // The screen was dismissed (or the refresh superseded) mid-fetch — not a user-facing error.
            return
        } catch {
            log.error("Error fetching categories navigation items for Shop screen: \(error)")
            // Re-check after the await: never downgrade a list already on screen — a concurrent
            // refresh may have succeeded while this (or an initial) fetch was in flight.
            if !state.isSuccess {
                state = .error(CategoriesViewErrorType.from(error: error))
            }
            return
        }

        guard !navigationItems.isEmpty else {
            if !state.isSuccess {
                state = .error(.noResults)
            }
            return
        }

        state = .success(.init(categories: navigationItems))
    }
}
