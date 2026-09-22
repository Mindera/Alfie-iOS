import Combine
import Foundation
import Model

public class MockProductDetailsViewModel: ProductDetailsViewModelProtocol {
    public var state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> = .loading

    public var productId: String = ""
    public var productTitle: String = ""
    public var productHasStock: Bool = true
    public var productHasAnyStock: Bool = true
    public var isAddToBagEnabled: Bool = true
    public var isAddingToBag: Bool = false
    public var addToBagFeedback: AddToBagFeedback?
    public var productName: String = ""
    public var productImageUrls: [URL] = []
    public var variantSelection: VariantSelectionState
    public var complementaryInfoToShow: [ProductDetailsComplementaryInfoType] = []
    public var productDescription: String = ""
    public var shareConfiguration: ShareConfiguration?
    public var shouldShowMediaPaginatedControl = true
    public var priceType: PriceType? = nil
    public var selectedColourName: String?
    public var productReference: String?
    public var relatedProductsState: ViewState<[Product], ProductDetailsViewErrorType> = .loading
    public var relatedProducts: [Product] { relatedProductsState.value ?? [] }
    public var isWishlistEnabled = true

    public init(state: ViewState<ProductDetailsViewStateModel, ProductDetailsViewErrorType> = .loading,
                productId: String = "",
                productTitle: String = "",
                productName: String = "",
                productImageUrls: [URL] = [],
                productDescription: String = "",
                selectedColourName: String? = nil,
                productReference: String? = nil,
                variantSelection: VariantSelectionState = .init(),
                complementaryInfoToShow: [ProductDetailsComplementaryInfoType] = [],
                onShouldShowLoadingForSectionCalled: ((ProductDetailsSection) -> Bool)? = nil,
                onShouldShowSectionCalled: ((ProductDetailsSection) -> Bool)? = nil) {
        self.state = state
        self.productId = productId
        self.productTitle = productTitle
        self.productName = productName
        self.productImageUrls = productImageUrls
        self.productDescription = productDescription
        self.selectedColourName = selectedColourName
        self.productReference = productReference
        self.variantSelection = variantSelection
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

    public var onDidDismissAddToBagFeedbackCalled: (() -> Void)?
    public func didDismissAddToBagFeedback() {
        onDidDismissAddToBagFeedbackCalled?()
    }

    public var onDidTapAddToWishlistCalled: (() -> Void)?
    public func didTapAddToWishlist() {
        onDidTapAddToWishlistCalled?()
    }

    public var onDidTapBackButtonCalled: (() -> Void)?
    public func didTapBackButton() {
        onDidTapBackButtonCalled?()
    }

    public var onOpenWebFeatureCalled: ((WebFeature) -> Void)?
    public func openWebFeature(_ feature: WebFeature) {
        onOpenWebFeatureCalled?(feature)
    }

    public var onDidSelectColourCalled: ((ColorSwatch) -> Void)?
    public func didSelectColour(_ swatch: ColorSwatch) {
        onDidSelectColourCalled?(swatch)
    }

    public var onDidSelectSizeCalled: ((SizingSwatch) -> Void)?
    public func didSelectSize(_ swatch: SizingSwatch) {
        onDidSelectSizeCalled?(swatch)
    }

    public var onDidSelectRelatedProductCalled: ((Product) -> Void)?
    public func didSelectRelatedProduct(_ product: Product) {
        onDidSelectRelatedProductCalled?(product)
    }

    public var onIsFavoriteStateCalled: ((Product) -> Bool)?
    public func isFavoriteState(for product: Product) -> Bool {
        onIsFavoriteStateCalled?(product) ?? false
    }

    public var onDidTapWishlistCalled: ((Product, Bool) -> Void)?
    public func didTapWishlist(for product: Product, isFavorite: Bool) {
        onDidTapWishlistCalled?(product, isFavorite)
    }
}
