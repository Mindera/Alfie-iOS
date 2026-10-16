import Combine
import Core
import Foundation
import Model
import SharedUI

public final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    let dependencies: ProductDetailsDependencyContainer
    // In case we already have a full or partial product to show while fetching
    private let baseProduct: Product?
    private let goBackAction: () -> Void
    private let openWebfeatureAction: (WebFeature) -> Void
    private let openProductAction: (Product) -> Void
    private var hasRequestedRelatedProducts = false

    @Published public private(set) var state: ViewState<
        ProductDetailsViewStateModel, ProductDetailsViewErrorType
    > = .loading
    @Published public private(set) var relatedProductsState: ViewState<
        [Product], ProductDetailsViewErrorType
    > = .loading
    @Published private(set) var wishlistContent: [SelectedProduct] = []
    @Published public internal(set) var isAddingToBag = false
    @Published public internal(set) var addToBagFeedback: AddToBagFeedback?
    @Published public internal(set) var isUpdatingBagQuantity = false
    @Published var cart: Cart?
    @Published var pendingBagQuantity: PendingBagQuantity?
    private var cartSubscription: AnyCancellable?
    let bagQuantityDebounce: Debounce
    @Published public private(set) var isInWishlist = false
    /// The only selection state on the PDP. Everything the shopper sees about colour, size, the
    /// chosen variant and whether the product can be bought is derived from it.
    var selection = VariantSelection(variants: [])
    /// Rebuilt when `selection` changes, not on every read: the view touches this several times per
    /// body pass and each rebuild rescans every variant. `displayVariant` and `addToBagState` are
    /// cached alongside it for the same reason.
    @Published public internal(set) var variantSelection = VariantSelectionState()
    @Published public internal(set) var addToBagState: AddToBagState = .outOfStock
    var displayVariant: Product.Variant?
    public let productId: String
    /// The BFF `productDetails(handle:)` argument. Sourced from the product `slug` where we have a
    /// product; for `.id` entry we only have the numeric id, which the BFF resolves for Shopify.
    private let productHandle: String
    private let initialSelectedProduct: SelectedProduct?
    let requestedSku: String?
    let requestedVariantId: String?

    var product: Product? {
        guard case .success(let model) = state else {
            return baseProduct
        }

        return model.product
    }

    var selectedVariant: Product.Variant? {
        displayVariant ?? initialSelectedProduct?.selectedVariant ?? baseProduct?.defaultVariant
    }

    public var productTitle: String { product?.brand.name ?? "" }
    public var productName: String { product?.name ?? "" }
    public var productImageUrls: [URL] { selectedVariant?.media.compactMap { $0.asImage?.url } ?? [] }
    public var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] {
        // Don't show delivery for now as we don't know yet if it will be a webview or an API-driven native page
        [.paymentOptions, .returns]
    }
    public var productDescription: String { product?.longDescription ?? "" }

    public var shareConfiguration: ShareConfiguration? {
        guard
            let product,
            let selectedVariant,
            state.isSuccess
        else {
            return nil
        }

        guard let url = dependencies.webUrlProvider.url(for: ProductURL(slug: product.slug)) else {
            return nil
        }

        let shareSubject = productName + " " + L10n.Pdp.ShareProduct.From.subject
        let selectedVariantAmount = selectedVariant.price.amount.amountFormatted
        let shareMessage = "\n" + productTitle + "\n" + productName + "\n" + selectedVariantAmount + "\n"

        return ShareConfiguration(url: url, message: shareMessage, subject: shareSubject)
    }

    public var shouldShowMediaPaginatedControl: Bool { productImageUrls.count > 1 }
    public var priceType: PriceType? { product?.priceType }
    // Empty collapses to nil so the metadata line omits the part rather than rendering a blank.
    public var selectedColourName: String? { selectedVariant?.colour?.name.nilWhenEmpty }
    public var productReference: String? { selectedVariant?.sku.nilWhenEmpty }
    public var isWishlistEnabled: Bool { dependencies.configurationService.isFeatureEnabled(.wishlist) }
    public var relatedProducts: [Product] { relatedProductsState.value ?? [] }

    public init(
        configuration: ProductDetailsConfiguration,
        dependencies: ProductDetailsDependencyContainer,
        goBackAction: @escaping () -> Void,
        openWebfeatureAction: @escaping (WebFeature) -> Void,
        openProductAction: @escaping (Product) -> Void
    ) {
        self.dependencies = dependencies
        self.goBackAction = goBackAction
        self.openWebfeatureAction = openWebfeatureAction
        self.openProductAction = openProductAction
        self.bagQuantityDebounce = Debounce(
            scheduler: dependencies.scheduler,
            delay: Constants.bagQuantityDebounce
        )

        switch configuration {
        case .id(let productId):
            self.productId = productId
            self.productHandle = productId
            self.initialSelectedProduct = nil
            self.requestedSku = nil
            self.requestedVariantId = nil
            self.baseProduct = nil

        case .deepLink(let handle, let sku, let variantId):
            self.productId = handle
            self.productHandle = handle
            self.initialSelectedProduct = nil
            self.requestedSku = sku
            self.requestedVariantId = variantId
            self.baseProduct = nil

        case .product(let product):
            self.productId = product.id
            self.productHandle = product.slug
            self.initialSelectedProduct = nil
            self.requestedSku = nil
            self.requestedVariantId = nil
            self.baseProduct = product

            updateSelection(VariantSelection(variants: product.variants, preferredVariant: product.defaultVariant))

        case .selectedProduct(let selectedProduct):
            self.productId = selectedProduct.product.id
            self.productHandle = selectedProduct.product.slug
            self.initialSelectedProduct = selectedProduct
            self.requestedSku = selectedProduct.selectedVariant.sku
            self.requestedVariantId = nil
            baseProduct = selectedProduct.product

            updateSelection(VariantSelection(
                variants: selectedProduct.product.variants,
                restoring: selectedProduct.selectedVariant
            ))
        }

        cartSubscription = dependencies.cartService.cartPublisher
            .receive(on: dependencies.scheduler)
            .sink { [weak self] cart in
                self?.cart = cart
            }
    }

    public func viewDidAppear() {
        Task {
            await loadRelatedProductsIfNeeded()
        }
        Task {
            await loadProductIfNeeded()
            await refreshWishlistState()
        }
        Task {
            await refreshWishlistContent()
        }
    }

    public func shouldShowLoading(for section: ProductDetailsSection) -> Bool {
        switch section {
        case .titleHeader:
            return state.isLoading && productName.isEmpty

        case .colorSelector,
             .sizeSelector, // swiftlint:disable:this indentation_width
             .mediaCarousel,
             .complementaryInfo:
            return state.isLoading

        case .productDescription,
             .addToBag, // swiftlint:disable:this indentation_width
             .addToWishlist,
             .availabilityNote:
            return false

        case .relatedProducts:
            return state.isSuccess && relatedProductsState.isLoading
        }
    }

    public func shouldShow(section: ProductDetailsSection) -> Bool {
        // swiftlint:disable vertical_whitespace_between_cases
        switch section {
        case .titleHeader,
             .colorSelector, // swiftlint:disable:this indentation_width
             .sizeSelector:
            return true
        case .complementaryInfo:
            return !complementaryInfoToShow.isEmpty
        case .mediaCarousel:
            return state.isLoading || !productImageUrls.isEmpty
        case .productDescription:
            return !productDescription.isEmpty
        // The note qualifies what the selectors' availability means, so it only belongs on screen
        // once there is real availability to qualify: while loading the swatches are shimmer
        // placeholders, and a failure draws no selectors at all. Same gate as the CTA.
        case .addToBag,
             .availabilityNote: // swiftlint:disable:this indentation_width
            return state.isSuccess
        case .addToWishlist:
            return state.isSuccess && isWishlistEnabled
        case .relatedProducts:
            return state.isSuccess && (relatedProductsState.isLoading || relatedProductsState.value?.isEmpty == false)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    public func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature? {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .delivery:
            return nil
        case .paymentOptions:
            return .paymentOptions
        case .returns:
            return .returnOptions
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    public func didTapAddToWishlist() {
        guard let selectedProduct else { return }
        let wasInWishlist = isInWishlist
        Task {
            if wasInWishlist {
                await dependencies.wishlistService.removeProduct(withId: selectedProduct.product.id)
                dependencies.analytics.trackRemoveFromWishlist(productID: selectedProduct.product.id)
            } else {
                await dependencies.wishlistService.addProduct(selectedProduct)
                dependencies.analytics.trackAddToWishlist(productID: selectedProduct.id)
            }
            await refreshWishlistState()
        }
    }

    public func didTapBackButton() {
        goBackAction()
    }

    public func openWebFeature(_ feature: WebFeature) {
        openWebfeatureAction(feature)
    }

    public func didSelectRelatedProduct(_ product: Product) {
        openProductAction(product)
    }

    public func isFavoriteState(for product: Product) -> Bool {
        wishlistContent.contains { $0.product.id == product.id }
    }

    public func didTapWishlist(for product: Product, isFavorite: Bool) {
        Task { @MainActor in
            if isFavorite {
                await dependencies.wishlistService.removeProduct(withId: product.id)
                dependencies.analytics.trackRemoveFromWishlist(productID: product.id)
            } else {
                await dependencies.wishlistService.addProduct(SelectedProduct(product: product))
                dependencies.analytics.trackAddToWishlist(productID: product.id)
            }
            wishlistContent = await dependencies.wishlistService.getWishlistContent()
        }
    }

    // MARK: - Private

    @MainActor
    private func loadRelatedProductsIfNeeded() async {
        guard !hasRequestedRelatedProducts else {
            return
        }
        hasRequestedRelatedProducts = true

        do {
            let products = try await dependencies.productService.relatedProducts(
                handle: productHandle,
                limit: Constants.relatedProductsRequestLimit
            )
            relatedProductsState = .success(
                Array(products.filter { !isCurrentProduct($0) }.prefix(Constants.relatedProductsMaxCount))
            )
        } catch {
            dependencies.log.error("Error fetching related products for \(productHandle): \(error)")
            relatedProductsState = .error(.from(error: error))
        }
    }

    private func isCurrentProduct(_ candidate: Product) -> Bool {
        candidate.slug == productHandle || candidate.id == productId
    }

    @MainActor
    private func refreshWishlistContent() async {
        wishlistContent = await dependencies.wishlistService.getWishlistContent()
    }

    @MainActor
    private func refreshWishlistState() async {
        let wishlistedProductId = product?.id ?? productId
        isInWishlist = await dependencies.wishlistService.getWishlistContent()
            .contains { $0.product.id == wishlistedProductId }
    }

    @MainActor
    private func loadProductIfNeeded() async {
        guard !state.isSuccess else {
            return
        }

        state = .loading

        let product: Product

        do {
            product = try await dependencies.productService.getProduct(handle: productHandle)
        } catch {
            dependencies.log.error("Error fetching product \(productId): \(error)")
            state = .error(ProductDetailsViewErrorType.from(error: error))
            return
        }

        updateSelection(selection(for: product))
        state = .success(.init(product: product))
    }

    var selectedProduct: SelectedProduct? {
        guard
            let product,
            let selectedVariant
        else {
            return initialSelectedProduct
        }

        return SelectedProduct(product: product, selectedVariant: selectedVariant)
    }
}

private extension String {
    var nilWhenEmpty: String? { isEmpty ? nil : self }
}

private enum Constants {
    static let bagQuantityDebounce: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
    static let relatedProductsMaxCount = 6
    static let relatedProductsRequestLimit = relatedProductsMaxCount + 1
}
