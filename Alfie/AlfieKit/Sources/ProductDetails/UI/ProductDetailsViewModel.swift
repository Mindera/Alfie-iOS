import Combine
import Core
import Foundation
import Model
import SharedUI

public final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    private let dependencies: ProductDetailsDependencyContainer
    // In case we already have a full or partial product to show while fetching
    private let baseProduct: Product?
    private let goBackAction: () -> Void
    private let openWebfeatureAction: (WebFeature) -> Void
    private let openProductAction: (Product) -> Void
    private var hasRequestedRelatedProducts = false

    @Published public private(set) var state: ViewState<
        ProductDetailsViewStateModel, ProductDetailsViewErrorType
    > = .loading
    @Published public private(set) var relatedProductsState: ViewState<[Product], ProductDetailsViewErrorType> = .loading
    @Published private(set) var wishlistContent: [SelectedProduct] = []
    @Published public private(set) var isAddingToBag = false
    @Published public private(set) var addToBagFeedback: AddToBagFeedback?
    /// The only selection state on the PDP. Everything the shopper sees about colour, size, the
    /// chosen variant and whether the product can be bought is derived from it.
    private var selection = VariantSelection(variants: [])
    /// Rebuilt when `selection` changes, not on every read: the view touches this several times per
    /// body pass and each rebuild rescans every variant.
    @Published public private(set) var variantSelection = VariantSelectionState()
    public let productId: String
    /// The BFF `productDetails(handle:)` argument. Sourced from the product `slug` where we have a
    /// product; for `.id` entry (deep link) we only have the numeric id today — see TODO in `init`.
    private let productHandle: String
    private let initialSelectedProduct: SelectedProduct?

    private var product: Product? {
        guard case .success(let model) = state else {
            return baseProduct
        }

        return model.product
    }

    private var selectedVariant: Product.Variant? {
        selection.displayVariant ?? initialSelectedProduct?.selectedVariant ?? baseProduct?.defaultVariant
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

        switch configuration {
        case .id(let productId):
            self.productId = productId
            self.productHandle = productId
            self.initialSelectedProduct = nil
            self.baseProduct = nil

        case .deepLink(let handle):
            self.productId = handle
            self.productHandle = handle
            self.initialSelectedProduct = nil
            self.baseProduct = nil

        case .product(let product):
            self.productId = product.id
            self.productHandle = product.slug
            self.initialSelectedProduct = nil
            self.baseProduct = product

            updateSelection(VariantSelection(variants: product.variants, preferredVariant: product.defaultVariant))

        case .selectedProduct(let selectedProduct):
            self.productId = selectedProduct.product.id
            self.productHandle = selectedProduct.product.slug
            self.initialSelectedProduct = selectedProduct
            baseProduct = selectedProduct.product

            updateSelection(VariantSelection(
                variants: selectedProduct.product.variants,
                preferredVariant: selectedProduct.selectedVariant
            ))
        }
    }

    public func viewDidAppear() {
        Task {
            await loadRelatedProductsIfNeeded()
        }
        Task {
            await loadProductIfNeeded()
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
             .addToWishlist:
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
        case .addToBag:
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

    public var productHasStock: Bool {
        (selectedVariant?.stock ?? 0) > 0
    }

    /// True when at least one variant of the product has stock.
    /// Use this for the CTA label (avoid showing "Out of Stock" while the product is still buyable in another size).
    public var productHasAnyStock: Bool {
        product?.variants.contains { $0.stock > 0 } ?? false
    }

    public var isAddToBagEnabled: Bool {
        selection.purchaseState.readyVariant != nil
    }

    public func didTapAddToBag() {
        // `isAddingToBag` flips before the Task is started, so a second tap while the first write
        // is still in flight is rejected here rather than becoming a second request.
        guard
            !isAddingToBag,
            let variant = selection.purchaseState.readyVariant,
            let variantId = variant.id,
            let product
        else {
            return
        }

        let selectedProduct = SelectedProduct(product: product, selectedVariant: variant)

        // Cleared up front so a second write with the same outcome is still a change the View
        // observes, rather than being swallowed as an unchanged value.
        addToBagFeedback = nil
        isAddingToBag = true
        Task { @MainActor in
            defer { isAddingToBag = false }
            do {
                // `product.id`, not `selectedProduct.id`: the latter is the composite
                // "<productId>-<sku>" used for local identity, which no platform would resolve.
                try await dependencies.cartService.add(
                    line: .init(productId: product.id, variantId: variantId)
                )
                // Only once the cart holds the line — firing on the tap would count adds that failed.
                // The composite id here is the pre-existing analytics shape, left alone per Q29.
                dependencies.analytics.trackAddToBag(productID: selectedProduct.id)
                addToBagFeedback = .success
            } catch {
                dependencies.log.error("Error adding \(selectedProduct.id) to the cart: \(error)")
                addToBagFeedback = .failure
            }
        }
    }

    public func didDismissAddToBagFeedback() {
        // Cleared on dismissal so an identical later outcome re-presents rather than being
        // swallowed as an unchanged value.
        addToBagFeedback = nil
    }

    public func didTapAddToWishlist() {
        guard let selectedProduct else { return }
        Task {
            await dependencies.wishlistService.addProduct(selectedProduct)
            dependencies.analytics.trackAddToWishlist(productID: selectedProduct.id)
        }
    }

    public func didTapBackButton() {
        goBackAction()
    }

    public func openWebFeature(_ feature: WebFeature) {
        openWebfeatureAction(feature)
    }

    public func didSelectColour(_ swatch: ColorSwatch) {
        updateSelection(selection.selecting(colourID: swatch.id))
    }

    public func didSelectSize(_ swatch: SizingSwatch) {
        updateSelection(selection.selecting(sizeID: swatch.id))
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
                limit: Self.relatedProductsRequestLimit
            )
            relatedProductsState = .success(
                Array(products.filter { !isCurrentProduct($0) }.prefix(Self.relatedProductsMaxCount))
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

        updateSelection(VariantSelection(
            variants: product.variants,
            preferredVariant: resolvedSelectedVariant(for: product)
        ))
        state = .success(.init(product: product))
    }

    /// When re-entering from Bag/Wishlist (`.selectedProduct`) the persisted variant carries a stale
    /// snapshot (e.g. out-of-date stock), so map the selection onto the freshly fetched product by
    /// `sku` — keeping the user's choice while reflecting current stock/price. Fall back to the
    /// product's default variant when there is no persisted selection or no match.
    private func resolvedSelectedVariant(for product: Product) -> Product.Variant {
        guard let persistedSku = initialSelectedProduct?.selectedVariant.sku else {
            return product.defaultVariant
        }
        return product.variants.first { $0.sku == persistedSku } ?? product.defaultVariant
    }

    /// The one way to move the selection, so the drawn state can never lag behind it.
    private func updateSelection(_ selection: VariantSelection) {
        // `@Published` publishes on every set, equal or not, and re-picking the current swatch
        // lands an identical selection. Guarding on the source rather than the derived state is
        // deliberate: `ColorSwatch` compares by id alone, so two equal `VariantSelectionState`s
        // can still draw different stock and swatch images after a refetch.
        guard selection != self.selection else { return }

        self.selection = selection
        let colours = selection.colours.map(colorSwatch(for:))
        let sizes = selection.sizes.map(sizingSwatch(for:))
        variantSelection = VariantSelectionState(
            colours: colours,
            selectedColour: colours.first { $0.id == selection.selectedColour?.id },
            sizes: sizes,
            selectedSize: sizes.first { $0.id == selection.selectedSize?.id }
        )
    }

    private func colorSwatch(for option: VariantSelection.ColourOption) -> ColorSwatch {
        let type: SwatchType = if let url = option.colour.swatch?.url {
            .url(url)
        } else {
            // A filled stand-in for a missing swatch image, so it reads as a surface token.
            .color(Theme.surfaceBackgroundInvertedPrimary)
        }

        return ColorSwatch(
            id: option.colour.id,
            name: option.colour.name,
            type: type,
            isDisabled: !option.isAvailable
        )
    }

    private func sizingSwatch(for option: VariantSelection.SizeOption) -> SizingSwatch {
        var name = option.size.value
        if let scale = option.size.scale {
            name += " \(scale)"
        }

        return SizingSwatch(id: option.size.id, name: name, state: option.isInStock ? .available : .outOfStock)
    }

    private var selectedProduct: SelectedProduct? {
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

extension ProductDetailsViewModel {
    private static let relatedProductsMaxCount = 6
    private static let relatedProductsRequestLimit = relatedProductsMaxCount + 1
}
