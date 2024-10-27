import Combine
import Foundation
import Models

public class MockProductDetailsViewModel: ProductDetailsViewModelProtocol {
    public var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> = .loading

    public var productId: String = ""
    public var productTitle: String = ""
    public var productHasStock: Bool = true
    public var productName: String = ""
    public var productImageUrls: [URL] = []
    public var colorSelectionConfiguration: ColorSelectorConfiguration = .init(items: [])
    public var sizingSelectionConfiguration: SizingSelectorConfiguration = .init(items: [])
    public var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] = []
    public var productDescription: String = ""
    public var shareConfiguration: ShareConfiguration?
    public var shouldShowMediaPaginatedControl = true
    public var hasSingleImage: Bool = false

    public init(state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> = .loading,
                productId: String = "",
                productTitle: String = "",
                productName: String = "",
                productImageUrls: [URL] = [],
                productDescription: String = "",
                colorSelectionConfiguration: ColorSelectorConfiguration = .init(items: []),
                complementaryInfoToShow: [ProductDetailsComplementaryInfoType] = [],
                onShouldShowLoadingForSectionCalled: ((ProductDetailsSection) -> Bool)? = nil,
                onShouldShowSectionCalled: ((ProductDetailsSection) -> Bool)? = nil) {
        self.state = state
        self.productId = productId
        self.productTitle = productTitle
        self.productName = productName
        self.productImageUrls = productImageUrls
        self.productDescription = productDescription
        self.colorSelectionConfiguration = colorSelectionConfiguration
        self.complementaryInfoToShow = complementaryInfoToShow
        self.onShouldShowLoadingForSectionCalled = onShouldShowLoadingForSectionCalled
        self.onShouldShowSectionCalled = onShouldShowSectionCalled
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onShouldShowLoadingForSectionCalled: ((ProductDetailsSection) -> Bool)?
    public func shouldShowLoading(for section: ProductDetailsSection) -> Bool {
        onShouldShowLoadingForSectionCalled?(section) ?? false
    }

    public var onComplementaryInfoWebFeatureForTypeCalled: ((ProductDetailsComplementaryInfoType) -> WebFeature?)?
    public func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature? {
        onComplementaryInfoWebFeatureForTypeCalled?(type)
    }

    public var onShouldShowSectionCalled: ((ProductDetailsSection) -> Bool)?
    public func shouldShow(section: ProductDetailsSection) -> Bool {
        onShouldShowSectionCalled?(section) ?? true
    }

    public var onDidTapAddToBagCalled: (() -> Void)?
    public func didTapAddToBag() {
        onDidTapAddToBagCalled?()
    }

    public var onColorSwatchesFilteredByCalled: ((String) -> [Models.ColorSwatch])?
    public func colorSwatches(filteredBy searchTerm: String) -> [Models.ColorSwatch] {
        onColorSwatchesFilteredByCalled?(searchTerm) ?? colorSelectionConfiguration.items
    }
    
    public var onSizingSwatchesFilteredByCalled: ((String) -> [Models.SizingSwatch])?
    public func sizingSwatches(filteredBy searchTerm: String) -> [Models.SizingSwatch] {
        onSizingSwatchesFilteredByCalled?(searchTerm) ?? sizingSelectionConfiguration.items
    }
}
