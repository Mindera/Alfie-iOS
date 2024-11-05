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
}

// MARK: - ProductDetailsComplementaryInfoType

public enum ProductDetailsComplementaryInfoType {
    case delivery
    case paymentOptions
    case returns
}

// MARK: - PriceType

public enum PriceType: Hashable {
    case `default`(price: String)
    case sale(fullPrice: String, finalPrice: String)
    case range(lowerBound: String, upperBound: String, separator: String)
}

// MARK: - ProductDetailsViewModelProtocol

public protocol ProductDetailsViewModelProtocol: ObservableObject {
    associatedtype ColorSelector: ColorSelectorProtocol
    associatedtype SizingSelector: SizingSelectorProtocol

    var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> { get }

    var productId: String { get }
    var productTitle: String { get }
    var productName: String { get }
    var productHasStock: Bool { get }
    var productImageUrls: [URL] { get }
    var productDescription: String { get }
    var colorSelectionConfiguration: ColorSelector { get }
    var sizingSelectionConfiguration: SizingSelector { get }
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
    func colorSwatches(filteredBy searchTerm: String) -> [ColorSelector.Swatch]
}
