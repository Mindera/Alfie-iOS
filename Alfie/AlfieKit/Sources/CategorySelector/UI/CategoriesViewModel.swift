import AlicerceLogging
import Combine
import Foundation
import Model
import Utils

public final class CategoriesViewModel: CategoriesViewModelProtocol {
    private enum Constants {
        static let placeholderTitleLowerBound: Int = 30
        static let placeholderTitleUpperBound: Int = 50
        static let placeholderItemCount: Int = 10
    }

    private let navigationService: NavigationServiceProtocol?
    private let log: Logger
    // True while a fetch is in flight, so concurrent loads/refreshes don't race (last-writer-wins).
    private var isFetching = false
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
    private var hasNavigationService: Bool { navigationService != nil }
    public var canRefresh: Bool { hasNavigationService }
    public var isRoot: Bool { hasNavigationService }
    private let navigate: (CategorySelectorRoute) -> Void

    init(
        navigationService: NavigationServiceProtocol,
        log: Logger,
        showToolbar: Bool = false,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.navigationService = navigationService
        self.log = log
        self.shouldShowToolbar = showToolbar
        self.navigate = navigate
    }

    init(
        log: Logger,
        categories: [NavigationItem],
        title: String,
        showToolbar: Bool = true,
        navigate: @escaping (CategorySelectorRoute) -> Void
    ) {
        self.log = log
        self.navigationService = nil
        self.state = .success(.init(categories: categories, title: title))
        self.shouldShowToolbar = showToolbar
        self.navigate = navigate
    }

    public func viewDidAppear() {
        Task {
            await loadItems()
        }
    }

    public func didSelectCategory(_ category: NavigationItem) {
        // The BFF menu is always a static store menu of collections: a category either drills into
        // its sub-menu, or (as a leaf) opens the PLP for its collection handle. No page/product links.
        if let subCategories = category.items, !subCategories.isEmpty {
            navigate(.subCategories(subCategories: subCategories, parent: category))
            return
        }

        guard let categoryUrl = category.url else {
            log.error("Error building URL for category from navigation item: \(category)")
            state = .error(.generic)
            return
        }

        let collectionHandle = categoryUrl.deletingPrefix("/")
        navigate(
            .productListing(
                .productListing(
                    .init(
                        category: collectionHandle,
                        searchText: nil,
                        urlQueryParameters: nil,
                        mode: .listing
                    )
                )
            )
        )
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
        // A drill-down screen has no service to retry against — bail before flipping to `.loading`,
        // which the no-op fetch would otherwise strand.
        guard canRefresh, !isFetching else { return }
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
            // A failed re-fetch must not downgrade the `.success` list already on screen.
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
