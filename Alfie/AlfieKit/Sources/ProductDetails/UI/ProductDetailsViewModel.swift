import Combine
import Core
import Foundation
import Model
import SharedUI

public final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    private let dependencies: ProductDetailsDependencyContainer
    // In case we already have a full or partial product to show while fetching
    private let baseProduct: Product?
    private var colorSelectionSubscription: AnyCancellable?
    private var sizingSelectionSubscription: AnyCancellable?
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
    @Published public private(set) var isUpdatingBagQuantity = false
    /// The cart as the service last published it. Held rather than read on demand so the stepper
    /// follows a change made anywhere else — the bag screen, or another PDP for the same variant.
    @Published private var cart: Cart?
    private var cartSubscription: AnyCancellable?
    @Published public private(set) var isInWishlist = false
    public private(set) var colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch> = .init(
        items: []
    )
    public private(set) var sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch> = .init(
        items: []
    )
    public let productId: String
    /// The BFF `productDetails(handle:)` argument. Sourced from the product `slug` where we have a
    /// product; for `.id` entry (deep link) we only have the numeric id today — see TODO in `init`.
    private let productHandle: String
    private let initialSelectedProduct: SelectedProduct?
    private let requestedSku: String?

    private var product: Product? {
        guard case .success(let model) = state else {
            return baseProduct
        }

        return model.product
    }

    private var selectedVariant: Product.Variant? {
        guard case .success(let model) = state else {
            return initialSelectedProduct?.selectedVariant ?? baseProduct?.defaultVariant
        }

        return model.selectedVariant
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
            self.requestedSku = nil
            self.baseProduct = nil

        case .deepLink(let handle, let sku):
            self.productId = handle
            self.productHandle = handle
            self.initialSelectedProduct = nil
            self.requestedSku = sku
            self.baseProduct = nil

        case .product(let product):
            self.productId = product.id
            self.productHandle = product.slug
            self.initialSelectedProduct = nil
            self.requestedSku = nil
            self.baseProduct = product

            buildColorAndSizingSelectionConfigurations(
                product: product,
                selectedVariant: product.defaultVariant
            )

        case .selectedProduct(let selectedProduct):
            self.productId = selectedProduct.product.id
            self.productHandle = selectedProduct.product.slug
            self.initialSelectedProduct = selectedProduct
            self.requestedSku = selectedProduct.selectedVariant.sku
            baseProduct = selectedProduct.product

            buildColorAndSizingSelectionConfigurations(
                product: selectedProduct.product,
                selectedVariant: selectedProduct.selectedVariant
            )
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

    public var productHasStock: Bool {
        (selectedVariant?.stock ?? 0) > 0
    }

    /// True when at least one variant of the product has stock.
    /// Use this for the CTA label (avoid showing "Out of Stock" while the product is still buyable in another size).
    public var productHasAnyStock: Bool {
        product?.variants.contains { $0.stock > 0 } ?? false
    }

    /// True when the user is offered an interactive size choice (more than one size swatch).
    /// When false, the size is implicit (sizeless product or a single available size).
    public var canShowSizeSelector: Bool {
        sizingSelectionConfiguration.items.count > 1
    }

    public var isAddToBagEnabled: Bool {
        productHasStock
            && selectedVariant?.id != nil
            && colorSelectionConfiguration.selectedItem != nil
            && (!canShowSizeSelector || sizingSelectionConfiguration.selectedItem != nil)
    }

    public func didTapAddToBag() {
        // `isAddingToBag` flips before the Task is started, so a second tap while the first write
        // is still in flight is rejected here rather than becoming a second request.
        guard
            isAddToBagEnabled,
            !isAddingToBag,
            let selectedProduct,
            let variantId = selectedVariant?.id
        else {
            return
        }

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
                    line: .init(productId: selectedProduct.product.id, variantId: variantId)
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

    /// The cart line holding the variant on screen, matched on `variantId` rather than product:
    /// a shopper who added the black one and switched to the blue is looking at a variant the bag
    /// does not hold, and must be offered Add to Bag rather than the black one's quantity.
    private var bagLine: CartLine? {
        guard
            let variantId = selectedVariant?.id,
            !canShowSizeSelector || sizingSelectionConfiguration.selectedItem != nil
        else {
            return nil
        }

        return cart?.lines.first { $0.variantId == variantId }
    }

    public var bagQuantity: Int {
        bagLine?.quantity ?? 0
    }

    public var maxBagQuantity: Int {
        Constants.maxLineQuantity
    }

    public func didTapIncreaseBagQuantity() {
        guard bagQuantity < maxBagQuantity else { return }

        setBagQuantity(to: bagQuantity + 1)
    }

    public func didTapDecreaseBagQuantity() {
        guard bagQuantity > 0 else { return }

        // Zero is a removal; `CartService` routes it to `removeFromCart` rather than a zero-quantity
        // update, and the stepper gives way to the Add to Bag CTA once the line is gone.
        setBagQuantity(to: bagQuantity - 1)
    }

    /// Pessimistic, like `didTapAddToBag()`: the number on screen is the one the server last
    /// confirmed, never one guessed ahead of it. `isUpdatingBagQuantity` flips before the Task
    /// starts, so a second tap mid-write is rejected here rather than becoming a request built from
    /// a quantity the server has already moved past.
    private func setBagQuantity(to quantity: Int) {
        guard !isUpdatingBagQuantity, !isAddingToBag, let line = bagLine, let selectedProduct else { return }

        let isIncrease = quantity > line.quantity
        addToBagFeedback = nil
        isUpdatingBagQuantity = true
        Task { @MainActor in
            defer { isUpdatingBagQuantity = false }
            do {
                try await dependencies.cartService.setQuantity(lineId: line.id, to: quantity)
                // Only once the cart holds the new quantity, matching `didTapAddToBag()`. The
                // composite id is that method's analytics shape, kept so one screen reports one id.
                if isIncrease {
                    dependencies.analytics.trackAddToBag(productID: selectedProduct.id)
                } else {
                    dependencies.analytics.trackRemoveFromBag(productID: selectedProduct.id)
                }
            } catch {
                dependencies.log.error("Error setting line \(line.id) to quantity \(quantity): \(error)")
                addToBagFeedback = .quantityUpdateFailure
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

    public func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch] {
        if searchTerm.isEmpty {
            colorSelectionConfiguration.items
        } else {
            colorSelectionConfiguration.items.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
        }
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

        let selectedVariant = resolvedSelectedVariant(for: product)
        buildColorAndSizingSelectionConfigurations(product: product, selectedVariant: selectedVariant)
        state = .success(.init(product: product, selectedVariant: selectedVariant))
    }

    /// When re-entering from Bag/Wishlist (`.selectedProduct`) the persisted variant carries a stale
    /// snapshot (e.g. out-of-date stock), so map the selection onto the freshly fetched product by
    /// `sku` — keeping the user's choice while reflecting current stock/price. A deep link's `sku`
    /// (a scanned Alfie code) is mapped the same way. Fall back to the product's default variant when
    /// there is no requested SKU or no match.
    private func resolvedSelectedVariant(for product: Product) -> Product.Variant {
        guard let requestedSku else {
            return product.defaultVariant
        }
        return product.variants.first { $0.sku == requestedSku } ?? product.defaultVariant
    }

    private func buildColorAndSizingSelectionConfigurations(product: Product, selectedVariant: Product.Variant) {
        buildColorSelectionConfiguration(product: product, selectedVariant: selectedVariant)
        buildSizingSelectionConfiguration(product: product, selectedVariant: selectedVariant)
    }

    private func buildColorSelectionConfiguration(product: Product, selectedVariant: Product.Variant?) {
        colorSelectionSubscription?.cancel()

        let colorSwatches = buildColorSwatches(product: product)

        var selectedSwatch: ColorSwatch?
        if let selectedVariant {
            selectedSwatch = colorSwatches.first { $0.id == selectedVariant.colour?.id }
        }

        colorSelectionConfiguration = .init(items: colorSwatches, selectedItem: selectedSwatch)
        colorSelectionSubscription = colorSelectionConfiguration.$selectedItem
            .receive(on: dependencies.scheduler)
            .dropFirst()
            .sink { [weak self] colorSwatch in
                guard let self, let colorSwatch else {
                    return
                }
                self.didSelect(colorSwatch: colorSwatch)
            }
    }

    private func buildColorSwatches(product: Product) -> [ColorSwatch] {
        let colors = buildVariantColors(product: product)
        return colors.map { color in
            var type: SwatchType
            if let url = color.swatch?.url {
                type = .url(url)
            } else {
                // A filled stand-in for a missing swatch image, so it reads as a surface token.
                type = .color(Theme.surfaceBackgroundInvertedPrimary)
            }

            let isAvailable = product.variants.contains { $0.colour?.id == color.id && $0.stock > 0 }

            return ColorSwatch(id: color.id, name: color.name, type: type, isDisabled: !isAvailable)
        }
    }

    private func buildVariantColors(product: Product) -> [Product.Colour] {
        // We could have used a Set<Product.Colour> or an OrderedSet and map the variants to it,
        // but we need to preserve the order returned by the API and it may not be the color ID ascending
        // so we map it manually
        var productColors = [Product.Colour]()
        product.variants.forEach { variant in
            guard let color = variant.colour, !productColors.contains(where: { $0.id == color.id }) else {
                return
            }
            productColors
                .append(Product.Colour(id: color.id, swatch: color.swatch, name: color.name, media: color.media))
        }
        return productColors
    }

    private func buildSizingSelectionConfiguration(product: Product, selectedVariant: Product.Variant?) {
        sizingSelectionSubscription?.cancel()

        let sizingSwatches = buildSizingSwatches(product: product, selectedVariant: selectedVariant)

        // Size is never auto-selected on PDP entry — the user must tap a swatch.
        sizingSelectionConfiguration = .init(
            selectedTitle: L10n.Product.Size.title + ":",
            items: sizingSwatches,
            selectedItem: nil
        )
        sizingSelectionSubscription = sizingSelectionConfiguration.$selectedItem
            .receive(on: dependencies.scheduler)
            .dropFirst()
            .sink { [weak self] sizingSwatch in
                guard let self, let sizingSwatch else {
                    return
                }
                self.didSelect(sizingSwatch: sizingSwatch)
            }
    }

    private func buildSizingSwatches(product: Product, selectedVariant: Product.Variant?) -> [SizingSwatch] {
        let sizes = buildVariantSizes(product: product, selectedVariant: selectedVariant)
        return sizes.map { size in
            let isAvailable = product.variants.contains { $0.size?.id == size.id && $0.stock > 0 }
            var sizeName = size.value
            if let scale = size.scale {
                sizeName += " \(scale)"
            }
            // TODO: Handle unavailable state if needed
            return SizingSwatch(id: size.id, name: sizeName, state: isAvailable ? .available : .outOfStock)
        }
    }

    private func buildVariantSizes(product: Product, selectedVariant: Product.Variant?) -> [Product.ProductSize] {
        let variantsForSelectedColor = product.variants.filter { $0.colour?.id == selectedVariant?.colour?.id }
        var productSizes = [Product.ProductSize]()
        variantsForSelectedColor.forEach { variant in
            guard let size = variant.size, !productSizes.contains(where: { $0.id == size.id }) else {
                return
            }
            productSizes.append(
                Product.ProductSize(
                    id: size.id,
                    value: size.value,
                    scale: size.scale,
                    description: size.description,
                    sizeGuide: size.sizeGuide
                )
            )
        }
        return productSizes
    }

    private func didSelect(colorSwatch: ColorSwatch) {
        guard let product else {
            dependencies.log.error("Tried to select color on inexistent product")
            return
        }

        guard let variant = product.variants.first(
            where: { $0.colour?.id == colorSwatch.id && $0.size?.id == selectedVariant?.size?.id }
        )
        else {
            dependencies.log.debug("Unexpected data inconsistency: tried to select color \(colorSwatch.id) on product \(productId) but no variant exists with that color, ignoring selection")
            return
        }

        state = .success(.init(product: product, selectedVariant: variant))
    }

    private func didSelect(sizingSwatch: SizingSwatch) {
        guard let product else {
            dependencies.log.error("Tried to select size on inexistent product")
            return
        }

        guard let variant = product.variants.first(
            where: { $0.size?.id == sizingSwatch.id && $0.colour?.id == selectedVariant?.colour?.id }
        )
        else {
            dependencies.log.debug("Unexpected data inconsistency: tried to select size \(sizingSwatch.id) on product \(productId) but no variant exists with that size, ignoring selection")
            return
        }

        state = .success(.init(product: product, selectedVariant: variant))
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

private enum Constants {
    /// The server's per-line ceiling (`Docs/Specs/Features/Cart.md`), not a stock figure — neither
    /// platform checks availability here. Enforced in the app so the shopper is stopped by a
    /// greyed-out control rather than by a `BAD_REQUEST` carrying the platform's raw wording.
    static let maxLineQuantity = 100
}
