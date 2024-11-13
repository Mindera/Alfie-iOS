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
    public var colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch>
    public var sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch>
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
                colorSelectionConfiguration: ColorAndSizingSelectorConfiguration<ColorSwatch> = .init(items: []),
                sizingSelectionConfiguration: ColorAndSizingSelectorConfiguration<SizingSwatch> = .init(items: []),
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
        self.sizingSelectionConfiguration = sizingSelectionConfiguration
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

    public var onDidTapAddToWishlistCalled: (() -> Void)?
    public func didTapAddToWishlist() {
        onDidTapAddToWishlistCalled?()
    }

    public var onColorSwatchesFilteredByCalled: ((String) -> [ColorSwatch])?
    public func colorSwatches(filteredBy searchTerm: String) -> [ColorSwatch] {
        onColorSwatchesFilteredByCalled?(searchTerm) ?? colorSelectionConfiguration.items
    }
}
