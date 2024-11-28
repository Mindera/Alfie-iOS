import Combine
import Common
import Core
import Foundation
import Models

// MARK: - ProductListingViewModel

final class ProductListingViewModel: ProductListingViewModelProtocol {
    private let dependencies: ProductListingDependencyContainerProtocol
    private let category: String?
    private let query: String?
    private let mode: ProductListingViewMode
    @Published var style: ProductListingListStyle
    @Published private(set) var wishListContent: [SelectionProduct]
    @Published private(set) var state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>

    private enum Constants {
        static let defaultSkeletonItemsSize = 12
    }

    var products: [Product] {
        state.value?.products ?? []
    }

    var title: String {
        state.value?.title ?? ""
    }

    var totalNumberOfProducts: Int {
        dependencies.productListingService.totalOfRecords ?? 0
    }

    var showSearchButton: Bool {
        !(state.isLoadingFirstPage || mode == .searchResults)
    }

    init(
        dependencies: ProductListingDependencyContainerProtocol,
        category: String? = nil,
        searchText: String? = nil,
        urlQueryParameters: [String: String]? = nil,
        mode: ProductListingViewMode = .listing,
        skeletonItemsSize: Int = Constants.defaultSkeletonItemsSize
    ) {
        self.dependencies = dependencies
        style = self.dependencies.plpStyleListProvider.style
        // TODO: - review filtering later, API not supporting for now
        self.category = category
        self.mode = mode
        query = searchText ?? urlQueryParameters.map(\.values)?.joined(separator: ",")
        state = .loadingFirstPage(.init(title: "", products: .skeleton(itemsSize: skeletonItemsSize)))
        wishListContent = dependencies.wishListService.getWishListContent()
    }

    func viewDidAppear() {
        wishListContent = dependencies.wishListService.getWishListContent()
        Task {
            await loadProductsIfNeeded()
        }
    }

    func didDisplay(_ product: Product) {
        if products.last?.id == product.id, !state.isLoadingNextPage {
            Task {
                await loadMoreProducts()
            }
        }
    }

    func setListStyle(_ style: ProductListingListStyle) {
        dependencies.plpStyleListProvider.set(style)
    }

    func didSelect(_: Product) {}

    func didTapAddToWishList(for product: Product, isFavorite: Bool) {
        if !isFavorite {
            let selectedProduct = SelectionProduct(
                id: product.defaultVariant.sku == "UNKNOWN" ? UUID().uuidString : product.defaultVariant.sku,
                name: product.name,
                brand: product.brand,
                size: product.defaultVariant.size,
                colour: product.defaultVariant.colour,
                stock: product.defaultVariant.stock,
                price: product.defaultVariant.price
            )
            dependencies.wishListService.addProduct(selectedProduct)
        } else {
            dependencies.wishListService.removeProductWith(
                colourId: product.defaultVariant.colour?.id,
                sizeId: product.defaultVariant.size?.id
            )
        }
        wishListContent = dependencies.wishListService.getWishListContent()
    }

    // MARK: - Private

    @MainActor
    private func loadProductsIfNeeded() async {
        guard !state.isSuccess else {
            return
        }

        let productListing: ProductListing?

        do {
            productListing = try await dependencies.productListingService.paged(categoryId: category, query: query)
        } catch {
            logError("Error fetching product listing (first page): \(error)")
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
            productListing = try await dependencies.productListingService.next(categoryId: category, query: query)
        } catch {
            logError("Error fetching product listing (following page): \(error)")
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
