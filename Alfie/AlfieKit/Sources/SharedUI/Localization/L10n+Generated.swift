// ⚠️ This file is automatically updated by SwiftGen - Do not modify ⚠️ — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - Strings

public enum L10n {
  public enum Account {
    /// Account
    public static let title = L10n.tr("L10n", "account.title")
  }
  public enum Bag {
    /// Bag
    public static let title = L10n.tr("L10n", "bag.title")
  }
  public enum FeatureToggle {
    /// Feature Toggle
    public static let title = L10n.tr("L10n", "feature_toggle.title")
    public enum AppUpdate {
      public enum Option {
        /// App Update
        public static let title = L10n.tr("L10n", "feature_toggle.app_update.option.title")
      }
    }
    public enum DebugConfiguration {
      public enum Option {
        /// Debug Configuration Enabled
        public static let title = L10n.tr("L10n", "feature_toggle.debug_configuration.option.title")
      }
    }
    public enum StoreServices {
      public enum Option {
        /// Store Services
        public static let title = L10n.tr("L10n", "feature_toggle.store_services.option.title")
      }
    }
    public enum Wishlist {
      public enum Option {
        /// Wishlist
        public static let title = L10n.tr("L10n", "feature_toggle.wishlist.option.title")
      }
    }
  }
  public enum Home {
    /// Home
    public static let title = L10n.tr("L10n", "home.title")
    public enum LoggedIn {
      /// Member Since: %@
      public static func subtitle(_ p1: Any) -> String {
        return L10n.tr("L10n", "home.logged_in.subtitle", String(describing: p1))
      }
      /// Hi, %@
      public static func title(_ p1: Any) -> String {
        return L10n.tr("L10n", "home.logged_in.title", String(describing: p1))
      }
    }
    public enum SearchBar {
      /// Search Alfie
      public static let placeholder = L10n.tr("L10n", "home.search_bar.placeholder")
    }
    public enum SignIn {
      public enum Button {
        /// Sign in
        public static let cta = L10n.tr("L10n", "home.sign_in.button.cta")
      }
    }
    public enum SignOut {
      public enum Button {
        /// Sign out
        public static let cta = L10n.tr("L10n", "home.sign_out.button.cta")
      }
    }
  }
  public enum Loading {
    /// Loading
    public static let title = L10n.tr("L10n", "loading.title")
  }
  public enum Pdp {
    public enum ComplementaryInfo {
      public enum Delivery {
        /// Delivery
        public static let title = L10n.tr("L10n", "pdp.complementary_info.delivery.title")
      }
      public enum Payment {
        /// Payment Options
        public static let title = L10n.tr("L10n", "pdp.complementary_info.payment.title")
      }
      public enum Returns {
        /// Returns Information
        public static let title = L10n.tr("L10n", "pdp.complementary_info.returns.title")
      }
    }
    public enum ErrorView {
      /// Oops!
      public static let title = L10n.tr("L10n", "pdp.error_view.title")
      public enum Generic {
        /// Something went wrong.
        public static let message = L10n.tr("L10n", "pdp.error_view.generic.message")
      }
      public enum GoBack {
        public enum Button {
          /// Go Back
          public static let cta = L10n.tr("L10n", "pdp.error_view.go_back.button.cta")
        }
      }
      public enum NotFound {
        /// The page you are looking for doesn’t exist.
        public static let message = L10n.tr("L10n", "pdp.error_view.not_found.message")
      }
    }
    public enum SearchColors {
      /// Search Colours
      public static let placeholder = L10n.tr("L10n", "pdp.search_colors.placeholder")
    }
    public enum ShareProduct {
      public enum From {
        /// from Alfie
        public static let subject = L10n.tr("L10n", "pdp.share_product.from.subject")
      }
    }
    public enum TabControl {
      public enum DescriptionOption {
        /// Description
        public static let title = L10n.tr("L10n", "pdp.tab_control.description_option.title")
      }
    }
  }
  public enum Plp {
    public enum ErrorView {
      /// Please try again later
      public static let message = L10n.tr("L10n", "plp.error_view.message")
      /// Cannot load products
      public static let title = L10n.tr("L10n", "plp.error_view.title")
    }
    public enum ListStyle {
      public enum Option {
        /// Page Style
        public static let title = L10n.tr("L10n", "plp.list_style.option.title")
      }
    }
    public enum NumberOfResults {
      /// Plural format key: plp.number_of_results.message
      public static func message(_ p1: Int) -> String {
        return L10n.tr("L10n", "plp.number_of_results.message", p1)
      }
    }
    public enum Refine {
      public enum Button {
        /// Refine
        public static let cta = L10n.tr("L10n", "plp.refine.button.cta")
      }
    }
    public enum RefineAndSort {
      /// Refine and Sort
      public static let title = L10n.tr("L10n", "plp.refine_and_sort.title")
    }
    public enum ShowResults {
      public enum Button {
        /// Show results
        public static let cta = L10n.tr("L10n", "plp.show_results.button.cta")
      }
    }
    public enum SortBy {
      public enum Option {
        /// Sort By
        public static let title = L10n.tr("L10n", "plp.sort_by.option.title")
      }
    }
  }
  public enum Product {
    public enum AddToBag {
      public enum Button {
        /// Add to bag
        public static let cta = L10n.tr("L10n", "product.add_to_bag.button.cta")
      }
    }
    public enum AddToWishlist {
      public enum Button {
        /// Add to wishlist
        public static let cta = L10n.tr("L10n", "product.add_to_wishlist.button.cta")
      }
    }
    public enum Color {
      /// Colour
      public static let title = L10n.tr("L10n", "product.color.title")
    }
    public enum OneSize {
      /// One Size
      public static let title = L10n.tr("L10n", "product.one_size.title")
    }
    public enum OutOfStock {
      public enum Button {
        /// Out of Stock
        public static let cta = L10n.tr("L10n", "product.out_of_stock.button.cta")
      }
    }
    public enum Size {
      /// Size
      static let title = L10n.tr("L10n", "product.size.title")
      enum NoSelection {
        /// Select a size
        static let title = L10n.tr("L10n", "product.size.no_selection.title")
      }
    }
  }
  public enum Search {
    public enum Screen {
      public enum EmptyView {
        /// Search for designers, categories and products
        public static let message = L10n.tr("L10n", "search.screen.empty_view.message")
        /// Find what you're looking for
        public static let title = L10n.tr("L10n", "search.screen.empty_view.title")
      }
      public enum NoResultsView {
        /// View all brands sold at Alfie
        public static let link = L10n.tr("L10n", "search.screen.no_results_view.link")
        /// Please check that you have typed the word correctly or broaden your search term.
        public static let message = L10n.tr("L10n", "search.screen.no_results_view.message")
        /// We were unable to find any results for your search ‘%@’
        public static func term(_ p1: Any) -> String {
          return L10n.tr("L10n", "search.screen.no_results_view.term", String(describing: p1))
        }
      }
      public enum RecentSearches {
        public enum ClearAll {
          public enum Button {
            /// Clear
            public static let cta = L10n.tr("L10n", "search.screen.recent_searches.clear_all.button.cta")
          }
        }
        public enum Header {
          /// Your Recent Searches
          public static let title = L10n.tr("L10n", "search.screen.recent_searches.header.title")
        }
      }
      public enum Suggestions {
        public enum More {
          public enum Button {
            /// More Products
            public static let cta = L10n.tr("L10n", "search.screen.suggestions.more.button.cta")
          }
        }
      }
      public enum SuggestionsBrands {
        public enum Header {
          /// Brand
          public static let title = L10n.tr("L10n", "search.screen.suggestions_brands.header.title")
        }
      }
      public enum SuggestionsProducts {
        public enum Header {
          /// Product Suggestions
          public static let title = L10n.tr("L10n", "search.screen.suggestions_products.header.title")
        }
      }
      public enum SuggestionsTerms {
        public enum Header {
          /// Search Suggestions
          public static let title = L10n.tr("L10n", "search.screen.suggestions_terms.header.title")
        }
      }
    }
  }
  public enum SearchBar {
    /// Cancel
    public static let cancel = L10n.tr("L10n", "search_bar.cancel")
    /// Search Alfie
    public static let placeholder = L10n.tr("L10n", "search_bar.placeholder")
    public enum Focused {
      /// What are you looking for?
      public static let placeholder = L10n.tr("L10n", "search_bar.focused.placeholder")
    }
  }
  public enum Shop {
    /// Shop
    public static let title = L10n.tr("L10n", "shop.title")
    public enum Brands {
      public enum ErrorView {
        /// Please try again later
        public static let message = L10n.tr("L10n", "shop.brands.error_view.message")
        /// Cannot load Brands list
        public static let title = L10n.tr("L10n", "shop.brands.error_view.title")
      }
      public enum SearchBar {
        /// Sorry, no results were found for
        public static let noResultsMessage = L10n.tr("L10n", "shop.brands.search_bar.no_results_message")
        /// Search Brands
        public static let placeholder = L10n.tr("L10n", "shop.brands.search_bar.placeholder")
      }
      public enum Segment {
        /// Brands
        public static let title = L10n.tr("L10n", "shop.brands.segment.title")
      }
    }
    public enum Categories {
      public enum ErrorView {
        /// Please try again later
        public static let message = L10n.tr("L10n", "shop.categories.error_view.message")
        /// Cannot load categories
        public static let title = L10n.tr("L10n", "shop.categories.error_view.title")
      }
      public enum Segment {
        /// Categories
        public static let title = L10n.tr("L10n", "shop.categories.segment.title")
      }
    }
    public enum Services {
      public enum Segment {
        /// Services
        public static let title = L10n.tr("L10n", "shop.services.segment.title")
      }
    }
  }
  public enum SortBy {
    public enum AlphaAsc {
      /// A-Z
      public static let title = L10n.tr("L10n", "sort_by.alpha_asc.title")
    }
    public enum AlphaDesc {
      /// Z-A
      public static let title = L10n.tr("L10n", "sort_by.alpha_desc.title")
    }
    public enum MostPopular {
      /// Most Popular
      public static let title = L10n.tr("L10n", "sort_by.most_popular.title")
    }
    public enum PriceHighToLow {
      /// Price-High to Low
      public static let title = L10n.tr("L10n", "sort_by.price_high_to_low.title")
    }
    public enum PriceLowToHigh {
      /// Price - Low to High
      public static let title = L10n.tr("L10n", "sort_by.price_low_to_high.title")
    }
  }
  public enum Tab {
    public enum Bag {
      /// Bag
      public static let title = L10n.tr("L10n", "tab.bag.title")
    }
    public enum Home {
      /// Home
      public static let title = L10n.tr("L10n", "tab.home.title")
    }
    public enum Shop {
      /// Shop
      public static let title = L10n.tr("L10n", "tab.shop.title")
    }
    public enum Wishlist {
      /// Wishlist
      public static let title = L10n.tr("L10n", "tab.wishlist.title")
    }
  }
  public enum WebView {
    public enum ErrorView {
      /// Oops!
      public static let title = L10n.tr("L10n", "web_view.error_view.title")
      public enum Button {
        /// Retry
        public static let cta = L10n.tr("L10n", "web_view.error_view.button.cta")
      }
      public enum Generic {
        /// Something went wrong.
        public static let message = L10n.tr("L10n", "web_view.error_view.generic.message")
      }
    }
    public enum PaymentOptionsFeature {
      /// Payment Options
      public static let title = L10n.tr("L10n", "web_view.payment_options_feature.title")
    }
    public enum ReturnOptionsFeature {
      /// Returns Information
      public static let title = L10n.tr("L10n", "web_view.return_options_feature.title")
    }
    public enum StoreServicesFeature {
      /// Store & Services
      public static let title = L10n.tr("L10n", "web_view.store_services_feature.title")
    }
  }
  public enum Wishlist {
    /// Wishlist
    public static let title = L10n.tr("L10n", "wishlist.title")
  }
}

// MARK: - Implementation Details

extension L10n {
    static func tr(
        _ table: String,
        _ key: StaticString,
        _ args: CVarArg...
    ) -> String {
        String(
            localized: key,
            defaultValue: defaultValue(key, args),
            table: table,
            bundle: BundleToken.bundle,
            locale: Locale.current
        )
    }

    private static func defaultValue(
        _ key: StaticString,
        _ args: CVarArg...
    ) -> String.LocalizationValue {
        var stringInterpolation = String.LocalizationValue.StringInterpolation(
            literalCapacity: 0,
            interpolationCount: args.count
        )
        args.forEach { stringInterpolation.appendInterpolation(arg: $0) }
        return .init(stringInterpolation: stringInterpolation)
    }
}

private extension String.LocalizationValue.StringInterpolation {
  mutating func appendInterpolation(arg: CVarArg) {
    switch arg {
    case let arg as String: appendInterpolation(arg)
    case let arg as Int: appendInterpolation(arg)
    case let arg as UInt: appendInterpolation(arg)
    case let arg as Double: appendInterpolation(arg)
    case let arg as Float: appendInterpolation(arg)
    default: return
    }
  }
}

#if DEBUG

// MARK: - Testable Keys

public extension L10n {
  enum Keys: String, RawRepresentable, CaseIterable {

      case accountTitle = "account.title"
      case bagTitle = "bag.title"
      case featureToggleTitle = "feature_toggle.title"
      case featureToggleAppUpdateOptionTitle = "feature_toggle.app_update.option.title"
      case featureToggleDebugConfigurationOptionTitle = "feature_toggle.debug_configuration.option.title"
      case featureToggleStoreServicesOptionTitle = "feature_toggle.store_services.option.title"
      case featureToggleWishlistOptionTitle = "feature_toggle.wishlist.option.title"
      case homeTitle = "home.title"
      case homeLoggedInSubtitle = "home.logged_in.subtitle"
      case homeLoggedInTitle = "home.logged_in.title"
      case homeSearchBarPlaceholder = "home.search_bar.placeholder"
      case homeSignInButtonCta = "home.sign_in.button.cta"
      case homeSignOutButtonCta = "home.sign_out.button.cta"
      case loadingTitle = "loading.title"
      case pdpComplementaryInfoDeliveryTitle = "pdp.complementary_info.delivery.title"
      case pdpComplementaryInfoPaymentTitle = "pdp.complementary_info.payment.title"
      case pdpComplementaryInfoReturnsTitle = "pdp.complementary_info.returns.title"
      case pdpErrorViewTitle = "pdp.error_view.title"
      case pdpErrorViewGenericMessage = "pdp.error_view.generic.message"
      case pdpErrorViewGoBackButtonCta = "pdp.error_view.go_back.button.cta"
      case pdpErrorViewNotFoundMessage = "pdp.error_view.not_found.message"
      case pdpSearchColorsPlaceholder = "pdp.search_colors.placeholder"
      case pdpShareProductFromSubject = "pdp.share_product.from.subject"
      case pdpTabControlDescriptionOptionTitle = "pdp.tab_control.description_option.title"
      case plpErrorViewMessage = "plp.error_view.message"
      case plpErrorViewTitle = "plp.error_view.title"
      case plpListStyleOptionTitle = "plp.list_style.option.title"
      case plpNumberOfResultsMessage = "plp.number_of_results.message"
      case plpRefineButtonCta = "plp.refine.button.cta"
      case plpRefineAndSortTitle = "plp.refine_and_sort.title"
      case plpShowResultsButtonCta = "plp.show_results.button.cta"
      case plpSortByOptionTitle = "plp.sort_by.option.title"
      case productAddToBagButtonCta = "product.add_to_bag.button.cta"
      case productAddToWishlistButtonCta = "product.add_to_wishlist.button.cta"
      case productColorTitle = "product.color.title"
      case productOneSizeTitle = "product.one_size.title"
      case productOutOfStockButtonCta = "product.out_of_stock.button.cta"
      case productSizeTitle = "product.size.title"
      case productSizeNoSelectionTitle = "product.size.no_selection.title"
      case searchScreenEmptyViewMessage = "search.screen.empty_view.message"
      case searchScreenEmptyViewTitle = "search.screen.empty_view.title"
      case searchScreenNoResultsViewLink = "search.screen.no_results_view.link"
      case searchScreenNoResultsViewMessage = "search.screen.no_results_view.message"
      case searchScreenNoResultsViewTerm = "search.screen.no_results_view.term"
      case searchScreenRecentSearchesClearAllButtonCta = "search.screen.recent_searches.clear_all.button.cta"
      case searchScreenRecentSearchesHeaderTitle = "search.screen.recent_searches.header.title"
      case searchScreenSuggestionsMoreButtonCta = "search.screen.suggestions.more.button.cta"
      case searchScreenSuggestionsBrandsHeaderTitle = "search.screen.suggestions_brands.header.title"
      case searchScreenSuggestionsProductsHeaderTitle = "search.screen.suggestions_products.header.title"
      case searchScreenSuggestionsTermsHeaderTitle = "search.screen.suggestions_terms.header.title"
      case searchBarCancel = "search_bar.cancel"
      case searchBarPlaceholder = "search_bar.placeholder"
      case searchBarFocusedPlaceholder = "search_bar.focused.placeholder"
      case shopTitle = "shop.title"
      case shopBrandsErrorViewMessage = "shop.brands.error_view.message"
      case shopBrandsErrorViewTitle = "shop.brands.error_view.title"
      case shopBrandsSearchBarNoResultsMessage = "shop.brands.search_bar.no_results_message"
      case shopBrandsSearchBarPlaceholder = "shop.brands.search_bar.placeholder"
      case shopBrandsSegmentTitle = "shop.brands.segment.title"
      case shopCategoriesErrorViewMessage = "shop.categories.error_view.message"
      case shopCategoriesErrorViewTitle = "shop.categories.error_view.title"
      case shopCategoriesSegmentTitle = "shop.categories.segment.title"
      case shopServicesSegmentTitle = "shop.services.segment.title"
      case sortByAlphaAscTitle = "sort_by.alpha_asc.title"
      case sortByAlphaDescTitle = "sort_by.alpha_desc.title"
      case sortByMostPopularTitle = "sort_by.most_popular.title"
      case sortByPriceHighToLowTitle = "sort_by.price_high_to_low.title"
      case sortByPriceLowToHighTitle = "sort_by.price_low_to_high.title"
      case tabBagTitle = "tab.bag.title"
      case tabHomeTitle = "tab.home.title"
      case tabShopTitle = "tab.shop.title"
      case tabWishlistTitle = "tab.wishlist.title"
      case webViewErrorViewTitle = "web_view.error_view.title"
      case webViewErrorViewButtonCta = "web_view.error_view.button.cta"
      case webViewErrorViewGenericMessage = "web_view.error_view.generic.message"
      case webViewPaymentOptionsFeatureTitle = "web_view.payment_options_feature.title"
      case webViewReturnOptionsFeatureTitle = "web_view.return_options_feature.title"
      case webViewStoreServicesFeatureTitle = "web_view.store_services_feature.title"
      case wishlistTitle = "wishlist.title"
  }
}
#endif

