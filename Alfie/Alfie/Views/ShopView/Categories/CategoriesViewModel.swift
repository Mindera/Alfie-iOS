import Combine
import Common
import Core
import Foundation
import Models

final class CategoriesViewModel: CategoriesViewModelProtocol {
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

    @Published private(set) var state: ViewState<CategoriesViewStateModel, CategoriesViewErrorType> = .loading
    lazy var openCategoryPublisher = openCategorySubject.eraseToAnyPublisher()

    var categories: [NavigationItem] {
        if state.isLoading {
            return placeholders
        }

        guard case .success(let model) = state else {
            return []
        }

        return model.categories
    }

    var title: String {
        guard case .success(let model) = state else {
            return ""
        }

        return model.title
    }

    private(set) var shouldShowToolbar: Bool

    init(navigationService: NavigationServiceProtocol, showToolbar: Bool = false) {
        self.navigationService = navigationService
        self.shouldShowToolbar = showToolbar
    }

    init(categories: [NavigationItem], title: String, showToolbar: Bool = true) {
        self.navigationService = nil
        self.state = .success(.init(categories: categories, title: title))
        self.shouldShowToolbar = showToolbar
    }

    func viewDidAppear() {
        Task {
            await loadItems()
        }
    }

    func didSelectCategory(_ category: NavigationItem) {
        // Special categories
        if let specialCategory = SpecialCategories.allCases.first(
            where: { $0.rawValue == category.url?.lowercased() }
        ) {
            openCategorySubject.send(specialCategory.destination)
            return
        }

        // If this category has sub-categories, show them, otherwise open the PLP
        if let subCategories = category.items, !subCategories.isEmpty {
            openCategorySubject.send(.subCategories(subCategories, parentCategory: category))
            return
        }

        guard
            var url = URL(string: "https://mock-server-rose.vercel.app"),
            let categoryUrl = category.url
        else {
            logError("Error building URL for category from navigation item: \(category)")
            state = .error(.generic)
            return
        }

        switch category.type {
        case .listing:
            openCategorySubject.send(.plp(category: categoryUrl.deletingPrefix("/")))

        case .externalHttp,
            .home,
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
            logError("Error fetching categories navigation items for Shop screen: \(error)")
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
