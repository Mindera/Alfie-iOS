import Foundation
import Model

public protocol ProductDetailsViewModelProtocol2: ObservableObject {
    var state: ViewState<ProductDetailsViewStateModel2, ProductDetailsViewErrorType2> { get }

    var productId: String { get }
    var productTitle: String { get }
    var productName: String { get }
    var productHasStock: Bool { get }
    var productImageUrls: [URL] { get }
    var productDescription: String { get }
    var colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch> { get }
    var sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch> { get }
    var complementaryInfoToShow: [ProductDetailsComplementaryInfoType2] { get }
    var shareConfiguration: ShareConfiguration? { get }
    var shouldShowMediaPaginatedControl: Bool { get }
    var hasSingleImage: Bool { get }
    var priceType: PriceType? { get }

    func viewDidAppear()
    func shouldShow(section: ProductDetailsSection2) -> Bool
    func shouldShowLoading(for section: ProductDetailsSection2) -> Bool
    func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType2) -> WebFeature?
    func didTapAddToBag()
    func didTapAddToWishlist()
    func didTapBackButton()
    func openWebFeature(_ feature: WebFeature)
    func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch]
}
