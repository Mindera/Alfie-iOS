import Combine
import Core
import Foundation
import Model
import SharedUI

public final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    private let dependencies: ProductDetailsDependencyContainer
    private let bag: BagLineEditor
    private var bagSubscription: AnyCancellable?
    private let baseProduct: Product?
    private let goBackAction: () -> Void
    private let openWebfeatureAction: (WebFeature) -> Void
    private let openProductAction: (Product) -> Void
    private var hasRequestedRelatedProducts = false
    private var isFetchingProduct = false

    @Published public private(set) var state: ViewState<
        ProductDetailsViewStateModel, ProductDetailsViewErrorType
    > = .loading
    @Published public private(set) var relatedProductsState: ViewState<
        [Product], ProductDetailsViewErrorType
    > = .loading
    @Published private(set) var wishlistContent: [SelectedProduct] = []
    @Published public private(set) var isAddingToBag = false
    @Published public private(set) var addToBagFeedback: AddToBagFeedback?
    @Published public private(set) var isUpdatingBagQuantity = false
    @Published public private(set) var isInWishlist = false
    /// The only selection state on the PDP. Everything the shopper sees about colour, size, the
    /// chosen variant and whether the product can be bought is derived from it.
    private var selection = VariantSelection(variants: [])
    /// Rebuilt when `selection` changes, not on every read: the view touches this several times per
    /// body pass and each rebuild rescans every variant. `displayVariant` and `addToBagState` are
    /// cached alongside it for the same reason.
    @Published public private(set) var variantSelection = VariantSelectionState()
    @Published public private(set) var addToBagState: AddToBagState = .outOfStock
    private var displayVariant: Product.Variant?
    public let productId: String
    /// The BFF `productDetails(handle:)` argument. Sourced from the product `slug` where we have a
    /// product; for `.id` entry we only have the numeric id, which the BFF resolves for Shopify.
    private let productHandle: String
    private let initialSelectedProduct: SelectedProduct?
    private let requestedSku: String?
    private let requestedVariantId: String?

    private var product: Product? {
        guard case .success(let model) = state else {
            return baseProduct
        }

        return model.product
    }

    private var selectedVariant: Product.Variant? {
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
        self.bag = BagLineEditor(dependencies: dependencies)

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

        bag.$isAdding.assign(to: &$isAddingToBag)
        bag.$feedback.assign(to: &$addToBagFeedback)
        bag.$isUpdating.assign(to: &$isUpdatingBagQuantity)
        // The bag quantity is read from the editor, so its changes have to reach this ViewModel's observers.
        bagSubscription = bag.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
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

    public func didTapRetry() {
        guard !state.isLoading else { return }

        state = .loading
        if !relatedProductsState.isLoading {
            relatedProductsState = .loading
            hasRequestedRelatedProducts = false
        }
        viewDidAppear()
    }

    public var bagQuantity: Int { bagLineProduct.map(bag.quantity(of:)) ?? 0 }
    public var maxBagQuantity: Int { bag.maxQuantity(of: selectedVariant) }

    public func didTapAddToBag() {
        guard let variant = selection.purchaseState.readyVariant, let product else { return }

        bag.add(SelectedProduct(product: product, selectedVariant: variant))
    }

    public func didTapIncreaseBagQuantity() {
        guard let item = bagLineProduct else { return }

        bag.increase(item)
    }

    public func didTapDecreaseBagQuantity() {
        guard let item = bagLineProduct else { return }

        bag.decrease(item)
    }

    public func didDismissAddToBagFeedback() {
        bag.dismissFeedback()
    }

    public func didSelectColour(_ swatch: ColorSwatch) {
        updateSelection(selection.selecting(colourID: swatch.id))
    }

    public func didSelectSize(_ swatch: SizingSwatch) {
        updateSelection(selection.selecting(sizeID: swatch.id))
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
        guard !state.isSuccess, !isFetchingProduct else {
            return
        }

        isFetchingProduct = true
        defer { isFetchingProduct = false }
        state = .loading

        let product: Product

        do {
            product = try await dependencies.productService.getProduct(handle: productHandle)
        } catch {
            dependencies.log.error("Error fetching product \(productId): \(error)")
            state = .error(ProductDetailsViewErrorType.from(error: error))
            return
        }

        updateSelection(VariantSelection(product: product, restoringSku: requestedSku, orVariantId: requestedVariantId))
        state = .success(.init(product: product))
    }

    /// The one way to move the selection, so the drawn state can never lag behind it.
    private func updateSelection(_ selection: VariantSelection) {
        // `@Published` publishes on every set, equal or not, and re-picking the current swatch
        // lands an identical selection. The guard sits on the source so that anything moving the
        // variants — a refetch carrying fresh stock — still reaches the swatches.
        guard selection != self.selection else { return }

        self.selection = selection
        variantSelection = VariantSelectionState(selection)
        displayVariant = selection.displayVariant
        addToBagState = AddToBagState(selection.purchaseState)
    }

    private var selectedProduct: SelectedProduct? {
        guard let product, let selectedVariant else { return initialSelectedProduct }

        return SelectedProduct(product: product, selectedVariant: selectedVariant)
    }

    /// The selected variant's bag line only counts once the shopper has a size to count it for.
    private var bagLineProduct: SelectedProduct? {
        guard variantSelection.sizeDisplay != .selector || variantSelection.selectedSize != nil else {
            return nil
        }

        return selectedProduct
    }
}

private extension String {
    var nilWhenEmpty: String? { isEmpty ? nil : self }
}

private enum Constants {
    static let relatedProductsMaxCount = 6
    static let relatedProductsRequestLimit = relatedProductsMaxCount + 1
}
