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
    }

    private let navigationService: NavigationServiceProtocol?
    private let log: Logger
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
        // Special categories
        if let specialCategory = SpecialCategories.allCases.first(
            where: { $0.rawValue == category.url?.lowercased() }
        ) {
            openCategorySubject.send(specialCategory.destination)
            guard !ignoreLocalNavigation, let url = ThemedURL.services.internalUrl else { return }
            ExternalAppLauncher.open(url: url)
            return
        }

        // If this category has sub-categories, show them, otherwise open the PLP
        if let subCategories = category.items, !subCategories.isEmpty {
            openCategorySubject.send(.subCategories(subCategories, parentCategory: category))
            navigate(.subCategories(subCategories: subCategories, parent: category))
            return
        }

        guard
            var url = URL(string: "https://\(ThemedURL.hostWithPortComponent)"),
            let categoryUrl = category.url
        else {
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
            let paths = categoryUrl.components(separatedBy: "/").filter { !$0.isEmpty }
            paths.forEach { path in
                url = url.appending(component: path)
            }
            openCategorySubject.send(.web(url: url, title: category.title))
            navigate(.web(url: url, title: category.title))
        }
    }

    // MARK: - Private

    @MainActor
    private func loadItems() async {
        guard let navigationService else {
            return
        }

        guard !state.isSuccess else {
            return
        }

        if !state.isLoading {
            state = .loading
        }

        let navigationItems: [NavigationItem]

        do {
            navigationItems = try await navigationService.getNavigationItems(for: .shop)
        } catch {
            log.error("Error fetching categories navigation items for Shop screen: \(error)")
            state = .error(.generic)
            return
        }

        guard !navigationItems.isEmpty else {
            state = .error(.noResults)
            return
        }

        state = .success(.init(categories: navigationItems))
    }
}
