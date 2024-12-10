import Combine
import Common
import Core
import Foundation
import Models
import StyleGuide

final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    private let dependencies: ProductDetailsDependencyContainerProtocol
    // In case we already have a full or partial product to show while fetching
    private let baseProduct: Product?
    private var colorSelectionSubscription: AnyCancellable?
    private var sizingSelectionSubscription: AnyCancellable?

    @Published private(set) var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> = .loading
    private(set) var colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch> = .init(items: [])
    private(set) var sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch> = .init(items: [])
    public let productId: String

    private var product: Product? {
        guard case .success(let model) = state else {
            return baseProduct
        }

        return model.product
    }

    private var selectedVariant: Product.Variant? {
        guard case .success(let model) = state else {
            return baseProduct?.defaultVariant
        }

        return model.selectedVariant
    }

    var productTitle: String {
        product?.brand.name ?? ""
    }

    var productName: String {
        product?.name ?? ""
    }

    var productImageUrls: [URL] {
        selectedVariant?.media.compactMap {
            $0.asImage?.url
        } ?? []
    }

    var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] {
        // Don't show delivery for now as we don't know yet if it will be a webview or an API-driven native page
        [.paymentOptions, .returns]
    }

    var productDescription: String {
        product?.longDescription ?? ""
    }

    var shareConfiguration: ShareConfiguration? {
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

        let shareSubject = productName + " " + LocalizableProductDetails.$shareTitleFrom
        let selectedVariantAmount = selectedVariant.price.amount.amountFormatted
        let shareMessage = "\n" + productTitle + "\n" + productName + "\n" + selectedVariantAmount + "\n"

        return ShareConfiguration(url: url, message: shareMessage, subject: shareSubject)
    }

    var shouldShowMediaPaginatedControl: Bool {
        productImageUrls.count > 1
    }

    var hasSingleImage: Bool {
        productImageUrls.count == 1
    }

    var priceType: PriceType? {
        product?.priceType
    }

    var shouldHideAction: Bool {
        !dependencies.configurationService.isFeatureEnabled(.wishlist)
    }

    init(productId: String, product: Product?, dependencies: ProductDetailsDependencyContainerProtocol) {
        self.productId = productId
        baseProduct = product
        self.dependencies = dependencies

        if let baseProduct {
            buildColorAndSizingSelectionConfigurations(
                product: baseProduct,
                selectedVariant: baseProduct.defaultVariant
            )
        }
    }

    func viewDidAppear() {
        Task {
            await loadProductIfNeeded()
        }
    }

    func shouldShowLoading(for section: ProductDetailsSection) -> Bool {
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
        }
    }

    func shouldShow(section: ProductDetailsSection) -> Bool {
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
            return state.isSuccess && dependencies.configurationService.isFeatureEnabled(.wishlist)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature? {
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

    var productHasStock: Bool {
        (selectedVariant?.stock ?? 0) > 0
    }

    func didTapAddToBag() {
        guard let selectedProduct else { return }
        dependencies.bagService.addProduct(selectedProduct)
    }

    func didTapAddToWishlist() {
        guard let selectedProduct else { return }
        dependencies.wishListService.addProduct(selectedProduct)
    }

    func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch] {
        if searchTerm.isEmpty {
            colorSelectionConfiguration.items
        } else {
            colorSelectionConfiguration.items.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
        }
    }

    // MARK: - Private

    @MainActor
    private func loadProductIfNeeded() async {
        guard !state.isSuccess else {
            return
        }

        state = .loading

        let product: Product

        do {
            product = try await dependencies.productService.getProduct(id: productId)
        } catch let error as BFFRequestError where error.isNotFound {
            logError("Product \(productId) not found.")
            state = .error(.notFound)
            return
        } catch {
            logError("Error fetching product \(productId): \(error)")
            state = .error(.generic)
            return
        }

        buildColorAndSizingSelectionConfigurations(product: product, selectedVariant: product.defaultVariant)
        state = .success(.init(product: product, selectedVariant: product.defaultVariant))
    }

    private func buildColorAndSizingSelectionConfigurations(product: Product, selectedVariant: Product.Variant?) {
        buildColorSelectionConfiguration(product: product, selectedVariant: product.defaultVariant)
        buildSizingSelectionConfiguration(product: product, selectedVariant: product.defaultVariant)
    }

    private func buildColorSelectionConfiguration(product: Product, selectedVariant: Product.Variant?) {
        colorSelectionSubscription?.cancel()

        let colorSwatches = buildColorSwatches(product: product)

        var selectedSwatch: ColorSwatch?
        if let selectedVariant {
            selectedSwatch = colorSwatches.first { $0.id == selectedVariant.colour?.id }
        }

        colorSelectionConfiguration = .init(
            selectedTitle: LocalizableGeneral.$color + ":",
            items: colorSwatches,
            selectedItem: selectedSwatch
        )
        colorSelectionSubscription = colorSelectionConfiguration.$selectedItem
            .receive(on: DispatchQueue.main)
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
                type = .color(Colors.primary.black)
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

        var selectedSwatch: SizingSwatch?
        if let selectedVariant {
            selectedSwatch = sizingSwatches.first { $0.id == selectedVariant.size?.id }
        }

        sizingSelectionConfiguration = .init(
            selectedTitle: LocalizableGeneral.$size + ":",
            items: sizingSwatches,
            selectedItem: selectedSwatch
        )
        sizingSelectionSubscription = sizingSelectionConfiguration.$selectedItem
            .receive(on: DispatchQueue.main)
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
            logError("Tried to select color on inexistent product")
            return
        }

        guard let variant = product.variants.first(
            where: { $0.colour?.id == colorSwatch.id && $0.size?.id == selectedVariant?.size?.id }
        )
        else {
            log("Unexpected data inconsistency: tried to select color \(colorSwatch.id) on product \(productId) but no variant exists with that color, ignoring selection")
            return
        }

        state = .success(.init(product: product, selectedVariant: variant))
    }

    private func didSelect(sizingSwatch: SizingSwatch) {
        guard let product else {
            logError("Tried to select size on inexistent product")
            return
        }

        guard let variant = product.variants.first(
            where: { $0.size?.id == sizingSwatch.id && $0.colour?.id == selectedVariant?.colour?.id }
        )
        else {
            log("Unexpected data inconsistency: tried to select size \(sizingSwatch.id) on product \(productId) but no variant exists with that size, ignoring selection")
            return
        }

        state = .success(.init(product: product, selectedVariant: variant))
    }

    private var selectedProduct: Product? {
        guard
            let product,
            let selectedVariant
        else {
            return nil
        }

        return Product(
            id: UUID().uuidString,
            styleNumber: product.styleNumber,
            name: product.name,
            brand: product.brand,
            shortDescription: product.shortDescription,
            longDescription: product.longDescription,
            slug: product.slug,
            priceRange: product.priceRange,
            attributes: product.attributes,
            defaultVariant: selectedVariant,
            variants: product.variants,
            colours: product.colours
        )
    }
}
