import Foundation

public protocol ProductDetailsViewModelProtocol: ObservableObject {
    var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> { get }

    var productId: String { get }
    var productTitle: String { get }
    var productName: String { get }
    var productHasStock: Bool { get }
    var productHasAnyStock: Bool { get }
    var isAddToBagEnabled: Bool { get }
    /// True while an add-to-bag write is in flight, so the CTA can show its loading state.
    var isAddingToBag: Bool { get }
    /// The outcome of the last add-to-bag write; nil once its Snackbar has been dismissed.
    var addToBagFeedback: AddToBagFeedback? { get }
    var productImageUrls: [URL] { get }
    var productDescription: String { get }
    /// Both selection axes and their highlights, derived together so they cannot disagree.
    var variantSelection: VariantSelectionState { get }
    var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] { get }
    var shareConfiguration: ShareConfiguration? { get }
    var shouldShowMediaPaginatedControl: Bool { get }
    var priceType: PriceType? { get }
    /// Selected variant's colour name, for the description metadata line.
    /// Nil for single-option products and the no-variant fallback.
    var selectedColourName: String? { get }
    /// Selected variant's SKU, rendered as the product reference.
    var productReference: String? { get }
    var relatedProductsState: ViewState<[Product], ProductDetailsViewErrorType> { get }
    var relatedProducts: [Product] { get }
    var isWishlistEnabled: Bool { get }

    func viewDidAppear()
    func shouldShow(section: ProductDetailsSection) -> Bool
    func shouldShowLoading(for section: ProductDetailsSection) -> Bool
    func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature?
    func didTapAddToBag()
    func didDismissAddToBagFeedback()
    func didTapAddToWishlist()
    func didTapBackButton()
    func openWebFeature(_ feature: WebFeature)
    func didSelectColour(_ swatch: ColorSwatch)
    func didSelectSize(_ swatch: SizingSwatch)
    func didSelectRelatedProduct(_ product: Product)
    func isFavoriteState(for product: Product) -> Bool
    func didTapWishlist(for product: Product, isFavorite: Bool)
}
