import Combine
import Core
import Foundation
import Model
import SwiftUI

// MARK: - ProductListingViewModel

public final class ProductListingViewModel2: ProductListingViewModelProtocol2 {
    private let dependencies: ProductListingDependencyContainer2
    private let category: String?
    private let query: String?
    private let mode: ProductListingViewMode2
    @Published public var style: ProductListingListStyle2
    @Published public var showRefine = false
    @Published public var sortOption: String?
    @Published public private(set) var wishlistContent: [SelectionProduct]
    private let navigate: (ProductListingRoute) -> Void
    @Published public private(set) var state: PaginatedViewState2<ProductListingViewStateModel2, ProductListingViewErrorType2>

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

    public init(
        dependencies: ProductListingDependencyContainer2,
        category: String? = nil,
        searchText: String? = nil,
        sort: String? = nil,
        urlQueryParameters: [String: String]? = nil,
        mode: ProductListingViewMode2 = .listing,
        skeletonItemsSize: Int = Constants.defaultSkeletonItemsSize,
        navigate: @escaping (ProductListingRoute) -> Void
    ) {
        self.dependencies = dependencies
        style = dependencies.plpStyleListProvider.style
        // TODO: - review filtering later, API not supporting for now
        self.category = category
        self.mode = mode
        sortOption = sort
        query = searchText ?? urlQueryParameters.map(\.values)?.joined(separator: ",")
        state = .loadingFirstPage(.init(title: "", products: .skeleton(itemsSize: skeletonItemsSize)))
        wishlistContent = dependencies.wishlistService.getWishlistContent()
        self.navigate = navigate
    }

    public func viewDidAppear() {
        wishlistContent = dependencies.wishlistService.getWishlistContent()
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

    public func setListStyle(_ style: ProductListingListStyle2) {
        dependencies.plpStyleListProvider.set(style)
    }

    public func didSelect(_ product: Product) {
        navigate(.productDetails(.productDetails(productID: product.id, product: product)))
    }

    public func isFavoriteState(for product: Product) -> Bool {
        wishlistContent.contains { $0.id == product.defaultVariant.sku }
    }

    public func didTapSearch() {
        navigate(.search)
    }

    public func didTapAddToWishlist(for product: Product, isFavorite: Bool) {
        if !isFavorite {
            let selectedProduct = SelectionProduct(product: product)
            dependencies.wishlistService.addProduct(selectedProduct)
            dependencies.analytics.trackAddToWishlist(productID: selectedProduct.id)
        } else {
            dependencies.wishlistService.removeProduct(product.defaultVariant.sku)
            dependencies.analytics.trackRemoveFromWishlist(productID: product.id)
        }
        wishlistContent = dependencies.wishlistService.getWishlistContent()
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
                .paged(categoryId: category, query: query, sort: sortOption)
        } catch {
//            log.error("Error fetching product listing (first page): \(error)")
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
                .next(categoryId: category, query: query, sort: sortOption)
        } catch {
//            log.error("Error fetching product listing (following page): \(error)")
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
