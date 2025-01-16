import Foundation

// swiftlint:disable line_length identifier_name
struct L10n: LocalizableProtocol {
    // MARK: - Account Screen

    @LocalizableResource<Self>(.accountScreenTitle) static var accountScreenTitle

    // MARK: - Bag Screen

    @LocalizableResource<Self>(.bagScreenTitle) static var bagScreenTitle

    // MARK: - Feature Toggle

    @LocalizableResource<Self>(.featureToggleAppUpdateOptionTitle) static var featureToggleAppUpdateOptionTitle
    @LocalizableResource<Self>(.featureToggleDebugConfigurationOptionTitle) static var featureToggleDebugConfigurationOptionTitle
    @LocalizableResource<Self>(.featureToggleScreenTitle) static var featureToggleScreenTitle
    @LocalizableResource<Self>(.featureToggleWishlistOptionTitle) static var featureToggleWishlistOptionTitle

    // MARK: - Home Screen

    static func homeScreenLoggedInSubtitleWithParameter(registrationYear: String) -> String {
        LocalizableResource<Self>(.homeScreenLoggedInSubtitle, arguments: registrationYear).projectedValue
    }

    static func homeScreenLoggedInTitleWithParameter(username: String) -> String {
        LocalizableResource<Self>(.homeScreenLoggedInTitle, arguments: username).projectedValue
    }

    @LocalizableResource<Self>(.homeScreenSearchBarPlaceholder) static var homeScreenSearchBarPlaceholder
    @LocalizableResource<Self>(.homeScreenSignInButtonCTA) static var homeScreenSignInButtonCTA
    @LocalizableResource<Self>(.homeScreenSignOutButtonCTA) static var homeScreenSignOutButtonCTA
    @LocalizableResource<Self>(.homeScreenTitle) static var homeScreenTitle

    // MARK: - Loading

    @LocalizableResource<Self>(.loadingTitle) static var loadingTitle

    // MARK: - Product details page

    @LocalizableResource<Self>(.pdpComplementaryInfoDeliveryTitle) static var pdpComplementaryInfoDeliveryTitle
    @LocalizableResource<Self>(.pdpComplementaryInfoPaymentTitle) static var pdpComplementaryInfoPaymentTitle
    @LocalizableResource<Self>(.pdpComplementaryInfoReturnsTitle) static var pdpComplementaryInfoReturnsTitle
    @LocalizableResource<Self>(.pdpErrorViewGenericMessage) static var pdpErrorViewGenericMessage
    @LocalizableResource<Self>(.pdpErrorViewGoBackButtonCTA) static var pdpErrorViewGoBackButtonCTA
    @LocalizableResource<Self>(.pdpErrorViewNotFoundMessage) static var pdpErrorViewNotFoundMessage
    @LocalizableResource<Self>(.pdpErrorViewTitle) static var pdpErrorViewTitle
    @LocalizableResource<Self>(.pdpSearchColorsPlaceholder) static var pdpSearchColorsPlaceholder
    @LocalizableResource<Self>(.pdpShareProductFromSubject) static var pdpShareProductFromSubject
    @LocalizableResource<Self>(.pdpTabControlDescriptionOptionTitle) static var pdpTabControlDescriptionOptionTitle

    // MARK: - Product list page

    @LocalizableResource<Self>(.plpErrorViewMessage) static var plpErrorViewMessage
    @LocalizableResource<Self>(.plpErrorViewTitle) static var plpErrorViewTitle
    @LocalizableResource<Self>(.plpListStyleOptionTitle) static var plpListStyleOptionTitle

    static func plpNumberOfResultsMessageWithParameter(_ results: Int) -> String {
        LocalizableResource<Self>(.plpNumberOfResultsMessage, arguments: results).projectedValue
    }

    @LocalizableResource<Self>(.plpRefineAndSortScreenTitle) static var plpRefineAndSortScreenTitle
    @LocalizableResource<Self>(.plpRefineButtonCTA) static var plpRefineButtonCTA
    @LocalizableResource<Self>(.plpShowResultsButtonCTA) static var plpShowResultsButtonCTA
    @LocalizableResource<Self>(.plpSortByOptionTitle) static var plpSortByOptionTitle

    // MARK: - Product

    @LocalizableResource<Self>(.productAddToBagButtonCTA) static var productAddToBagButtonCTA
    @LocalizableResource<Self>(.productAddToWishlistButtonCTA) static var productAddToWishlistButtonCTA
    @LocalizableResource<Self>(.productColorTitle) static var productColorTitle
    @LocalizableResource<Self>(.productOneSizeTitle) static var productOneSizeTitle
    @LocalizableResource<Self>(.productOutOfStockButtonCTA) static var productOutOfStockButtonCTA
    @LocalizableResource<Self>(.productSizeTitle) static var productSizeTitle

    // MARK: - Search

    @LocalizableResource<Self>(.searchBarCancel) static var searchBarCancel
    @LocalizableResource<Self>(.searchBarFocusedPlaceholder) static var searchBarFocusedPlaceholder
    @LocalizableResource<Self>(.searchBarPlaceholder) static var searchBarPlaceholder
    @LocalizableResource<Self>(.searchScreenEmptyViewMessage) static var searchScreenEmptyViewMessage
    @LocalizableResource<Self>(.searchScreenEmptyViewTitle) static var searchScreenEmptyViewTitle
    @LocalizableResource<Self>(.searchScreenNoResultsViewLink) static var searchScreenNoResultsViewLink
    @LocalizableResource<Self>(.searchScreenNoResultsViewMessage) static var searchScreenNoResultsViewTitle

    static func searchScreenNoResultsViewTermWithParameter(term: String) -> String {
        LocalizableResource<Self>(.searchScreenNoResultsViewTerm, arguments: term).projectedValue
    }

    @LocalizableResource<Self>(.searchScreenRecentSearchesClearAllButtonCTA) static var searchScreenRecentSearchesClearAllButtonCTA
    @LocalizableResource<Self>(.searchScreenRecentSearchesHeaderTitle) static var searchScreenRecentSearchesHeaderTitle
    @LocalizableResource<Self>(.searchScreenSuggestionsBrandsHeaderTitle) static var searchScreenSuggestionsBrandsHeaderTitle
    @LocalizableResource<Self>(.searchScreenSuggestionsMoreButtonCTA) static var searchScreenSuggestionsMoreButtonCTA
    @LocalizableResource<Self>(.searchScreenSuggestionsProductsHeaderTitle) static var searchScreenSuggestionsProductsHeaderTitle
    @LocalizableResource<Self>(.searchScreenSuggestionsTermsHeaderTitle) static var searchScreenSuggestionsTermsHeaderTitle

    // MARK: - Shop Screen

    @LocalizableResource<Self>(.shopBrandsErrorViewMessage) static var shopBrandsErrorViewMessage
    @LocalizableResource<Self>(.shopBrandsErrorViewTitle) static var shopBrandsErrorViewTitle
    @LocalizableResource<Self>(.shopBrandsSearchBarNoResultsMessage) static var shopBrandsSearchBarNoResultsMessage
    @LocalizableResource<Self>(.shopBrandsSearchBarPlaceholder) static var shopBrandsSearchBarPlaceholder
    @LocalizableResource<Self>(.shopCategoriesErrorViewMessage) static var shopCategoriesErrorViewMessage
    @LocalizableResource<Self>(.shopCategoriesErrorViewTitle) static var shopCategoriesErrorViewTitle
    @LocalizableResource<Self>(.shopScreenBrandsSegmentTitle) static var shopScreenBrandsSegmentTitle
    @LocalizableResource<Self>(.shopScreenCategoriesSegmentTitle) static var shopScreenCategoriesSegmentTitle
    @LocalizableResource<Self>(.shopScreenServicesSegmentTitle) static var shopScreenServicesSegmentTitle
    @LocalizableResource<Self>(.shopScreenTitle) static var shopScreenTitle

    // MARK: - Sort by

    @LocalizableResource<Self>(.sortByAlphaAscTitle) static var sortByAlphaAscTitle
    @LocalizableResource<Self>(.sortByAlphaDescTitle) static var sortByAlphaDescTitle
    @LocalizableResource<Self>(.sortByMostPopularTitle) static var sortByMostPopularTitle
    @LocalizableResource<Self>(.sortByNewInTitle) static var sortByNewInTitle
    @LocalizableResource<Self>(.sortByPriceHighToLowTitle) static var sortByPriceHighToLowTitle
    @LocalizableResource<Self>(.sortByPriceLowToHigh) static var sortByPriceLowToHigh

    // MARK: - Tabs

    @LocalizableResource<Self>(.tabBagTitle) static var tabBagTitle
    @LocalizableResource<Self>(.tabHomeTitle) static var tabHomeTitle
    @LocalizableResource<Self>(.tabShopTitle) static var tabShopTitle
    @LocalizableResource<Self>(.tabWishlistTitle) static var tabWishlistTitle

    // MARK: - WebView

    @LocalizableResource<Self>(.webViewErrorViewButtonCTA) static var webViewErrorViewButtonCTA
    @LocalizableResource<Self>(.webViewErrorViewGenericMessage) static var webViewErrorViewGenericMessage
    @LocalizableResource<Self>(.webViewErrorViewTitle) static var webViewErrorViewTitle
    @LocalizableResource<Self>(.webViewPaymentOptionsFeatureTitle) static var webViewPaymentOptionsFeatureTitle
    @LocalizableResource<Self>(.webViewReturnOptionsFeatureTitle) static var webViewReturnOptionsFeatureTitle
    @LocalizableResource<Self>(.webViewStoreServicesFeatureTitle) static var webViewStoreServicesFeatureTitle

    // MARK: - Wishlist Screen

    @LocalizableResource<Self>(.wishlistScreenTitle) static var wishlistScreenTitle
}
// swiftlint:enable line_length identifier_name
