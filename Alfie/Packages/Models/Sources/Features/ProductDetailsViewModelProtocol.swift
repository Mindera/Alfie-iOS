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

// MARK: - ProductDetailsViewModelProtocol

public protocol ProductDetailsViewModelProtocol: ObservableObject {
    var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> { get }

    var productId: String { get }
    var productTitle: String { get }
    var productName: String { get }
    var productHasStock: Bool { get }
    var productImageUrls: [URL] { get }
    var productDescription: String { get }
    var colorSelectionConfiguration: ColorSelectorConfiguration { get }
    var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] { get }
    var shareConfiguration: ShareConfiguration? { get }
    var shouldShowMediaPaginatedControl: Bool { get }
    var hasSingleImage: Bool { get }

    func viewDidAppear()
    func shouldShow(section: ProductDetailsSection) -> Bool
    func shouldShowLoading(for section: ProductDetailsSection) -> Bool
    func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature?
    func didTapAddToBag()
    func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch]
}
