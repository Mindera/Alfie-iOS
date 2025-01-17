import Foundation

extension L10n {
    enum Keys: String, RawRepresentable, CaseIterable {
        // MARK: - Account Screen

        case accountTitle = "account.title"

        // MARK: - Bag Screen

        case bagTitle = "bag.title"

        // MARK: - Feature Toggle

        case featureToggleAppUpdateOptionTitle = "feature_toggle.app_update.option.title"
        case featureToggleDebugConfigurationOptionTitle = "feature_toggle.debug_configuration.option.title"
        case featureToggleTitle = "feature_toggle.title"
        case featureToggleWishlistOptionTitle = "feature_toggle.wishlist.option.title"

        // MARK: - Home Screen

        case homeLoggedInTitle = "home.logged_in.title"
        case homeLoggedInSubtitle = "home.logged_in.subtitle"
        case homeSearchBarPlaceholder = "home.search_bar.placeholder"
        case homeSignInButtonCTA = "home.sign_in.button.cta"
        case homeSignOutButtonCTA = "home.sign_out.button.cta"
        case homeTitle = "home.title"

        // MARK: - Loading

        case loadingTitle = "loading.title"

        // MARK: - Product details page

        case pdpComplementaryInfoDeliveryTitle = "pdp.complementary_info.delivery.title"
        case pdpComplementaryInfoPaymentTitle = "pdp.complementary_info.payment.title"
        case pdpComplementaryInfoReturnsTitle = "pdp.complementary_info.returns.title"
        case pdpErrorViewGenericMessage = "pdp.error_view.generic.message"
        case pdpErrorViewGoBackButtonCTA = "pdp.error_view.go_back.button.cta"
        case pdpErrorViewNotFoundMessage = "pdp.error_view.not_found.message"
        case pdpErrorViewTitle = "pdp.error_view.title"
        case pdpSearchColorsPlaceholder = "pdp.search_colors.placeholder"
        case pdpShareProductFromSubject = "pdp.share_product.from.subject"
        case pdpTabControlDescriptionOptionTitle = "pdp.tab_control.description_option.title"

        // MARK: - Product list page

        case plpErrorViewTitle = "plp.error_view.title"
        case plpErrorViewMessage = "plp.error_view.message"
        case plpListStyleOptionTitle = "plp.list_style.option.title"
        case plpNumberOfResultsMessage = "plp.number_of_results.message"
        case plpRefineAndSortTitle = "plp.refine_and_sort.title"
        case plpRefineButtonCTA = "plp.refine.button.cta"
        case plpShowResultsButtonCTA = "plp.show_results.button.cta"
        case plpSortByOptionTitle = "plp.sort_by.option.title"

        // MARK: - Product

        case productAddToBagButtonCTA = "product.add_to_bag.button.cta"
        case productAddToWishlistButtonCTA = "product.add_to_wishlist.button.cta"
        case productColorTitle = "product.color.title"
        case productOneSizeTitle = "product.one_size.title"
        case productOutOfStockButtonCTA = "product.out_of_stock.button.cta"
        case productSizeTitle = "product.size.title"

        // MARK: - Search

        case searchBarCancel = "search_bar.cancel"
        case searchBarFocusedPlaceholder = "search_bar.focused.placeholder"
        case searchBarPlaceholder = "search_bar.placeholder"
        case searchScreenEmptyViewMessage = "search.screen.empty_view.message"
        case searchScreenEmptyViewTitle = "search.screen.empty_view.title"
        case searchScreenNoResultsViewLink = "search.screen.no_results_view.link"
        case searchScreenNoResultsViewMessage = "search.screen.no_results_view.message"
        case searchScreenNoResultsViewTerm = "search.screen.no_results_view.term"
        case searchScreenRecentSearchesClearAllButtonCTA = "search.screen.recent_searches.clear_all.button.cta"
        case searchScreenRecentSearchesHeaderTitle = "search.screen.recent_searches.header.title"
        case searchScreenSuggestionsBrandsHeaderTitle = "search.screen.suggestions_brands.header.title"
        case searchScreenSuggestionsMoreButtonCTA = "search.screen.suggestions.more.button.cta"
        case searchScreenSuggestionsProductsHeaderTitle = "search.screen.suggestions_products.header.title"
        case searchScreenSuggestionsTermsHeaderTitle = "search.screen.suggestions_terms.header.title"

        // MARK: - Shop Screen

        case shopBrandsErrorViewMessage = "shop.brands.error_view.message"
        case shopBrandsErrorViewTitle = "shop.brands.error_view.title"
        case shopBrandsSearchBarNoResultsMessage = "shop.brands.search_bar.no_results_message"
        case shopBrandsSearchBarPlaceholder = "shop.brands.search_bar.placeholder"
        case shopCategoriesErrorViewMessage = "shop.categories.error_view.message"
        case shopCategoriesErrorViewTitle = "shop.categories.error_view.title"
        case shopBrandsSegmentTitle = "shop.brands.segment.title"
        case shopCategoriesSegmentTitle = "shop.categories.segment.title"
        case shopServicesSegmentTitle = "shop.services.segment.title"
        case shopTitle = "shop.title"

        // MARK: - Sort by

        case sortByAlphaAscTitle = "sort_by.alpha_asc.title"
        case sortByAlphaDescTitle = "sort_by.alpha_desc.title"
        case sortByMostPopularTitle = "sort_by.most_popular.title"
        case sortByNewInTitle = "sort_by.new_in.title"
        case sortByPriceHighToLowTitle = "sort_by.price_high_to_low.title"
        case sortByPriceLowToHigh = "sort_by.price_low_to_high.title"

        // MARK: - Tabs

        case tabBagTitle = "tab.bag.title"
        case tabHomeTitle = "tab.home.title"
        case tabShopTitle = "tab.shop.title"
        case tabWishlistTitle = "tab.wishlist.title"

        // MARK: - WebView

        case webViewErrorViewButtonCTA = "web_view.error_view.button.cta"
        case webViewErrorViewGenericMessage = "web_view.error_view.generic.message"
        case webViewErrorViewTitle = "web_view.error_view.title"
        case webViewPaymentOptionsFeatureTitle = "web_view.payment_options_feature.title"
        case webViewReturnOptionsFeatureTitle = "web_view.return_options_feature.title"
        case webViewStoreServicesFeatureTitle = "web_view.store_services_feature.title"

        // MARK: - Wishlist Screen

        case wishlistTitle = "wishlist.title"
    }
}
