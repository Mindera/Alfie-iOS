import Combine
import Foundation

// MARK: - ProductDetailsViewStateModel

public struct ProductDetailsViewStateModel {
    public let product: Product
    public let selectedVariant: Product.Variant

    public init(product: Product, selectedVariant: Product.Variant) {
        self.product = product
        self.selectedVariant = selectedVariant
    }
}

// MARK: - ProductDetailsViewErrorType

public enum ProductDetailsViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case notFound
}

// MARK: - ProductDetailsSection

public enum ProductDetailsSection {
    case titleHeader
    case colorSelector
    case sizeSelector
    case mediaCarousel
    case complementaryInfo
    case productDescription
    case addToBag
    case addToWishlist
}

// MARK: - ProductDetailsComplementaryInfoType

public enum ProductDetailsComplementaryInfoType {
    case delivery
    case paymentOptions
    case returns
}

// MARK: - PriceType

public enum PriceType {
    case `default`(price: String)
    case sale(fullPrice: String, finalPrice: String)
    case range(lowerBound: String, upperBound: String, separator: String)
}

// MARK: - ProductDetailsViewModelProtocol

public protocol ProductDetailsViewModelProtocol: ToolbarModifierContainerViewModelProtocol, ObservableObject {
    var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> { get }

    var productId: String { get }
    var productTitle: String { get }
    var productName: String { get }
    var productHasStock: Bool { get }
    var productImageUrls: [URL] { get }
    var productDescription: String { get }
    var colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch> { get }
    var sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch> { get }
    var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] { get }
    var shareConfiguration: ShareConfiguration? { get }
    var shouldShowMediaPaginatedControl: Bool { get }
    var hasSingleImage: Bool { get }
    var priceType: PriceType? { get }

    func viewDidAppear()
    func shouldShow(section: ProductDetailsSection) -> Bool
    func shouldShowLoading(for section: ProductDetailsSection) -> Bool
    func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature?
    func didTapAddToBag()
    func didTapAddToWishlist()
    func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch]
}
