import Foundation

extension L10n {
    // MARK: - Account Screen

    @Resource(.accountTitle) static var accountTitle

    // MARK: - Bag Screen

    @Resource(.bagTitle) static var bagTitle

    // MARK: - Feature Toggle

    @Resource(.featureToggleAppUpdateOptionTitle) static var featureToggleAppUpdateOptionTitle
    @Resource(.featureToggleDebugConfigurationOptionTitle) static var featureToggleDebugConfigurationOptionTitle
    @Resource(.featureToggleTitle) static var featureToggleTitle
    @Resource(.featureToggleWishlistOptionTitle) static var featureToggleWishlistOptionTitle

    // MARK: - Home Screen

    static func homeLoggedInTitleWithParameter(username: String) -> String {
        Resource(.homeLoggedInTitle, arguments: username).projectedValue
    }

    static func homeLoggedInSubtitleWithParameter(registrationYear: String) -> String {
        Resource(.homeLoggedInSubtitle, arguments: registrationYear).projectedValue
    }

    @Resource(.homeSearchBarPlaceholder) static var homeSearchBarPlaceholder
    @Resource(.homeSignInButtonCTA) static var homeSignInButtonCTA
    @Resource(.homeSignOutButtonCTA) static var homeSignOutButtonCTA
    @Resource(.homeTitle) static var homeTitle

    // MARK: - Loading

    @Resource(.loadingTitle) static var loadingTitle

    // MARK: - Product details page

    @Resource(.pdpComplementaryInfoDeliveryTitle) static var pdpComplementaryInfoDeliveryTitle
    @Resource(.pdpComplementaryInfoPaymentTitle) static var pdpComplementaryInfoPaymentTitle
    @Resource(.pdpComplementaryInfoReturnsTitle) static var pdpComplementaryInfoReturnsTitle
    @Resource(.pdpErrorViewGenericMessage) static var pdpErrorViewGenericMessage
    @Resource(.pdpErrorViewGoBackButtonCTA) static var pdpErrorViewGoBackButtonCTA
    @Resource(.pdpErrorViewNotFoundMessage) static var pdpErrorViewNotFoundMessage
    @Resource(.pdpErrorViewTitle) static var pdpErrorViewTitle
    @Resource(.pdpSearchColorsPlaceholder) static var pdpSearchColorsPlaceholder
    @Resource(.pdpShareProductFromSubject) static var pdpShareProductFromSubject
    @Resource(.pdpTabControlDescriptionOptionTitle) static var pdpTabControlDescriptionOptionTitle

    // MARK: - Product list page

    @Resource(.plpErrorViewTitle) static var plpErrorViewTitle
    @Resource(.plpErrorViewMessage) static var plpErrorViewMessage
    @Resource(.plpListStyleOptionTitle) static var plpListStyleOptionTitle

    static func plpNumberOfResultsMessageWithParameter(_ results: Int) -> String {
        Resource(.plpNumberOfResultsMessage, arguments: results).projectedValue
    }

    @Resource(.plpRefineAndSortTitle) static var plpRefineAndSortTitle
    @Resource(.plpRefineButtonCTA) static var plpRefineButtonCTA
    @Resource(.plpShowResultsButtonCTA) static var plpShowResultsButtonCTA
    @Resource(.plpSortByOptionTitle) static var plpSortByOptionTitle

    // MARK: - Product

    @Resource(.productAddToBagButtonCTA) static var productAddToBagButtonCTA
    @Resource(.productAddToWishlistButtonCTA) static var productAddToWishlistButtonCTA
    @Resource(.productColorTitle) static var productColorTitle
    @Resource(.productOneSizeTitle) static var productOneSizeTitle
    @Resource(.productOutOfStockButtonCTA) static var productOutOfStockButtonCTA
    @Resource(.productSizeTitle) static var productSizeTitle

    // MARK: - Search

    @Resource(.searchBarCancel) static var searchBarCancel
    @Resource(.searchBarFocusedPlaceholder) static var searchBarFocusedPlaceholder
    @Resource(.searchBarPlaceholder) static var searchBarPlaceholder
    @Resource(.searchScreenEmptyViewMessage) static var searchScreenEmptyViewMessage
    @Resource(.searchScreenEmptyViewTitle) static var searchScreenEmptyViewTitle
    @Resource(.searchScreenNoResultsViewLink) static var searchScreenNoResultsViewLink
    @Resource(.searchScreenNoResultsViewMessage) static var searchScreenNoResultsViewTitle

    static func searchScreenNoResultsViewTermWithParameter(term: String) -> String {
        Resource(.searchScreenNoResultsViewTerm, arguments: term).projectedValue
    }

    @Resource(.searchScreenRecentSearchesClearAllButtonCTA) static var searchScreenRecentSearchesClearAllButtonCTA
    @Resource(.searchScreenRecentSearchesHeaderTitle) static var searchScreenRecentSearchesHeaderTitle
    @Resource(.searchScreenSuggestionsBrandsHeaderTitle) static var searchScreenSuggestionsBrandsHeaderTitle
    @Resource(.searchScreenSuggestionsMoreButtonCTA) static var searchScreenSuggestionsMoreButtonCTA
    @Resource(.searchScreenSuggestionsProductsHeaderTitle) static var searchScreenSuggestionsProductsHeaderTitle
    @Resource(.searchScreenSuggestionsTermsHeaderTitle) static var searchScreenSuggestionsTermsHeaderTitle

    // MARK: - Shop Screen

    @Resource(.shopBrandsErrorViewMessage) static var shopBrandsErrorViewMessage
    @Resource(.shopBrandsErrorViewTitle) static var shopBrandsErrorViewTitle
    @Resource(.shopBrandsSearchBarNoResultsMessage) static var shopBrandsSearchBarNoResultsMessage
    @Resource(.shopBrandsSearchBarPlaceholder) static var shopBrandsSearchBarPlaceholder
    @Resource(.shopCategoriesErrorViewMessage) static var shopCategoriesErrorViewMessage
    @Resource(.shopCategoriesErrorViewTitle) static var shopCategoriesErrorViewTitle
    @Resource(.shopBrandsSegmentTitle) static var shopBrandsSegmentTitle
    @Resource(.shopCategoriesSegmentTitle) static var shopCategoriesSegmentTitle
    @Resource(.shopServicesSegmentTitle) static var shopServicesSegmentTitle
    @Resource(.shopTitle) static var shopTitle

    // MARK: - Sort by

    @Resource(.sortByAlphaAscTitle) static var sortByAlphaAscTitle
    @Resource(.sortByAlphaDescTitle) static var sortByAlphaDescTitle
    @Resource(.sortByMostPopularTitle) static var sortByMostPopularTitle
    @Resource(.sortByNewInTitle) static var sortByNewInTitle
    @Resource(.sortByPriceHighToLowTitle) static var sortByPriceHighToLowTitle
    @Resource(.sortByPriceLowToHigh) static var sortByPriceLowToHigh

    // MARK: - Tabs

    @Resource(.tabBagTitle) static var tabBagTitle
    @Resource(.tabHomeTitle) static var tabHomeTitle
    @Resource(.tabShopTitle) static var tabShopTitle
    @Resource(.tabWishlistTitle) static var tabWishlistTitle

    // MARK: - WebView

    @Resource(.webViewErrorViewButtonCTA) static var webViewErrorViewButtonCTA
    @Resource(.webViewErrorViewGenericMessage) static var webViewErrorViewGenericMessage
    @Resource(.webViewErrorViewTitle) static var webViewErrorViewTitle
    @Resource(.webViewPaymentOptionsFeatureTitle) static var webViewPaymentOptionsFeatureTitle
    @Resource(.webViewReturnOptionsFeatureTitle) static var webViewReturnOptionsFeatureTitle
    @Resource(.webViewStoreServicesFeatureTitle) static var webViewStoreServicesFeatureTitle

    // MARK: - Wishlist Screen

    @Resource(.wishlistTitle) static var wishlistTitle
}
