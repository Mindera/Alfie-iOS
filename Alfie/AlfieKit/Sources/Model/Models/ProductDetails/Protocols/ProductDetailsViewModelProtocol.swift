import Foundation

public protocol ProductDetailsViewModelProtocol: ObservableObject {
    var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> { get }

    var productId: String { get }
    var productTitle: String { get }
    var productName: String { get }
    var productHasStock: Bool { get }
    var productHasAnyStock: Bool { get }
    var isAddToBagEnabled: Bool { get }
    var canShowSizeSelector: Bool { get }
    var productImageUrls: [URL] { get }
    var productDescription: String { get }
    var colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch> { get }
    var sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch> { get }
    var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] { get }
    var shareConfiguration: ShareConfiguration? { get }
    var shouldShowMediaPaginatedControl: Bool { get }
    var hasSingleImage: Bool { get }
    var priceType: PriceType? { get }
    /// Selected variant's colour name, for the description metadata line.
    /// Nil for single-option products and the no-variant fallback.
    var selectedColourName: String? { get }
    /// Selected variant's SKU, rendered as the product reference.
    var productReference: String? { get }

    func viewDidAppear()
    func shouldShow(section: ProductDetailsSection) -> Bool
    func shouldShowLoading(for section: ProductDetailsSection) -> Bool
    func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature?
    func didTapAddToBag()
    func didTapAddToWishlist()
    func didTapBackButton()
    func openWebFeature(_ feature: WebFeature)
    func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch]
}
