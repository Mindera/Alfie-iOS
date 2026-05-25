import Combine
import Core
import Foundation
import Model
import SwiftUI

// MARK: - ProductListingViewModel

public final class ProductListingViewModel: ProductListingViewModelProtocol {
    private let dependencies: ProductListingDependencyContainer
    private let category: String?
    private let query: String?
    private let mode: ProductListingViewMode
    @Published public var style: ProductListingListStyle
    @Published public var showRefine = false
    @Published public var sortOption: String?
    // ALFMOB-331 AC 4: BFF `ProductFilterInput` shape is plumbed end-to-end. The Refine UI
    // doesn't expose filter dimensions yet, so this stays `nil` until a follow-up wires the
    // sheet to populate it (brandNames / productTypes / price range / inventory).
    @Published public var filters: ProductFilterInput?
    @Published public private(set) var wishlistContent: [SelectedProduct]
    private let navigate: (ProductListingRoute) -> Void
    private let showSearch: () -> Void
    @Published public private(set) var state: PaginatedViewState<
        ProductListingViewStateModel, ProductListingViewErrorType
    >

    public enum Constants {
        public static let defaultSkeletonItemsSize = 12
    }

    public var products: [Product] {
        state.value?.products ?? []
    }

    public var title: String {
        state.value?.title ?? ""
    }

    public var totalNumberOfProducts: Int {
        dependencies.productListingService.totalOfRecords ?? 0
    }

    public var showSearchButton: Bool {
        !(state.isLoadingFirstPage || mode == .searchResults)
    }

    public var isWishlistEnabled: Bool {
        dependencies.configurationService.isFeatureEnabled(.wishlist)
    }

    public init(
        dependencies: ProductListingDependencyContainer,
        category: String? = nil,
        searchText: String? = nil,
        sort: String? = nil,
        urlQueryParameters: [String: String]? = nil,
        mode: ProductListingViewMode = .listing,
        skeletonItemsSize: Int = Constants.defaultSkeletonItemsSize,
        navigate: @escaping (ProductListingRoute) -> Void,
        showSearch: @escaping () -> Void
    ) {
        self.dependencies = dependencies
        style = dependencies.plpStyleListProvider.style
        self.category = category
        self.mode = mode
        sortOption = sort
        query = searchText ?? urlQueryParameters.map(\.values)?.joined(separator: ",")
        state = .loadingFirstPage(.init(title: "", products: .skeleton(itemsSize: skeletonItemsSize)))
        wishlistContent = []
        self.navigate = navigate
        self.showSearch = showSearch
    }

    public func viewDidAppear() {
        Task { @MainActor in
            wishlistContent = await dependencies.wishlistService.getWishlistContent()
        }
        Task {
            await loadProductsIfNeeded()
        }
    }

    public func didDisplay(_ product: Product) {
        guard products.last?.id == product.id, !state.isLoadingNextPage else { return }

        Task {
            await loadMoreProducts()
        }
    }

    public func setListStyle(_ style: ProductListingListStyle) {
        dependencies.plpStyleListProvider.set(style)
    }

    public func didSelect(_ product: Product) {
        navigate(.productDetails(.productDetails(.product(product))))
    }

    public func isFavoriteState(for product: Product) -> Bool {
        wishlistContent.contains { $0.product.id == product.id }
    }

    public func didTapSearch() {
        showSearch()
    }

    public func didTapAddToWishlist(for product: Product, isFavorite: Bool) {
        Task { @MainActor in
            if !isFavorite {
                await dependencies.wishlistService.addProduct(SelectedProduct(product: product))
                dependencies.analytics.trackAddToWishlist(productID: product.id)
            } else {
                await dependencies.wishlistService.removeProduct(withId: product.id)
                dependencies.analytics.trackRemoveFromWishlist(productID: product.id)
            }
            wishlistContent = await dependencies.wishlistService.getWishlistContent()
        }
    }

    public func didApplyFilters() {
        showRefine = false
        state = .loadingFirstPage(.init(title: "", products: []))

        Task {
            await loadProductsIfNeeded()
        }
    }

    // MARK: - Private

    @MainActor
    private func loadProductsIfNeeded() async {
        guard !state.isSuccess else {
            return
        }

        let productListing: ProductListing?

        do {
            productListing = try await dependencies.productListingService
                .paged(categoryId: category, query: query, sort: sortOption, filters: filters)
        } catch {
            dependencies.log.error("Error fetching product listing (first page): \(error)")
            state = .error(.generic)
            return
        }

        guard let productListing else {
            state = .error(.noResults)
            return
        }

        state = .success(.init(title: productListing.title, products: productListing.products))
    }

    @MainActor
    private func loadMoreProducts() async {
        guard dependencies.productListingService.hasNext(), case .success(let model) = state else {
            return
        }

        state = .loadingNextPage(.init(title: title, products: products))
        let productListing: ProductListing?

        do {
            productListing = try await dependencies.productListingService
                .next(categoryId: category, query: query, sort: sortOption, filters: filters)
        } catch {
            dependencies.log.error("Error fetching product listing (following page): \(error)")
            state = .error(.generic)
            return
        }

        guard let productListing else {
            state = .error(.noResults)
            return
        }

        state = .success(.init(title: title, products: model.products + productListing.products))
    }
}

// MARK: - Skeleton

extension Collection where Element == Product {
    // swiftlint:disable:next strict_fileprivate
    fileprivate static func skeleton(itemsSize: Int) -> [Element] {
        Array(repeating: (), count: itemsSize).map { Element.empty }
    }
}

extension Product {
    // swiftlint:disable:next strict_fileprivate
    fileprivate static var empty: Product {
        let variant = Product.Variant(
            sku: "",
            size: nil,
            colour: nil,
            attributes: nil,
            stock: 0,
            price: .init(amount: .init(currencyCode: "AUD", amount: 0, amountFormatted: "$000,00"), was: nil)
        )
        return Product(
            id: UUID().uuidString,
            styleNumber: "",
            name: "",
            brand: Brand(id: "", name: "", slug: ""),
            shortDescription: "",
            slug: "",
            defaultVariant: variant,
            variants: [variant],
            colours: nil
        )
    }
}
