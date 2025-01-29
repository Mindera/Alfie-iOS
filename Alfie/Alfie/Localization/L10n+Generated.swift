
// ⚠️ This file is automatically updated by SwiftGen - Do not modify ⚠️ — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - Strings

enum L10n {
  enum Account {
    /// Account
    static let title = L10n.tr("L10n", "account.title")
  }
  enum Bag {
    /// Bag
    static let title = L10n.tr("L10n", "bag.title")
  }
  enum FeatureToggle {
    /// Feature Toggle
    static let title = L10n.tr("L10n", "feature_toggle.title")
    enum AppUpdate {
      enum Option {
        /// App Update
        static let title = L10n.tr("L10n", "feature_toggle.app_update.option.title")
      }
    }
    enum DebugConfiguration {
      enum Option {
        /// Debug Configuration Enabled
        static let title = L10n.tr("L10n", "feature_toggle.debug_configuration.option.title")
      }
    }
    enum Wishlist {
      enum Option {
        /// Wishlist
        static let title = L10n.tr("L10n", "feature_toggle.wishlist.option.title")
      }
    }
  }
  enum Home {
    /// Home
    static let title = L10n.tr("L10n", "home.title")
    enum LoggedIn {
      /// Member Since: %@
      static func subtitle(_ p1: Any) -> String {
        return L10n.tr("L10n", "home.logged_in.subtitle", String(describing: p1))
      }
      /// Hi, %@
      static func title(_ p1: Any) -> String {
        return L10n.tr("L10n", "home.logged_in.title", String(describing: p1))
      }
    }
    enum SearchBar {
      /// Search Alfie
      static let placeholder = L10n.tr("L10n", "home.search_bar.placeholder")
    }
    enum SignIn {
      enum Button {
        /// Sign in
        static let cta = L10n.tr("L10n", "home.sign_in.button.cta")
      }
    }
    enum SignOut {
      enum Button {
        /// Sign out
        static let cta = L10n.tr("L10n", "home.sign_out.button.cta")
      }
    }
  }
  enum Loading {
    /// Loading
    static let title = L10n.tr("L10n", "loading.title")
  }
  enum Pdp {
    enum ComplementaryInfo {
      enum Delivery {
        /// Delivery
        static let title = L10n.tr("L10n", "pdp.complementary_info.delivery.title")
      }
      enum Payment {
        /// Payment Options
        static let title = L10n.tr("L10n", "pdp.complementary_info.payment.title")
      }
      enum Returns {
        /// Returns Information
        static let title = L10n.tr("L10n", "pdp.complementary_info.returns.title")
      }
    }
    enum ErrorView {
      /// Oops!
      static let title = L10n.tr("L10n", "pdp.error_view.title")
      enum Generic {
        /// Something went wrong.
        static let message = L10n.tr("L10n", "pdp.error_view.generic.message")
      }
      enum GoBack {
        enum Button {
          /// Go Back
          static let cta = L10n.tr("L10n", "pdp.error_view.go_back.button.cta")
        }
      }
      enum NotFound {
        /// The page you are looking for doesn’t exist.
        static let message = L10n.tr("L10n", "pdp.error_view.not_found.message")
      }
    }
    enum SearchColors {
      /// Search Colours
      static let placeholder = L10n.tr("L10n", "pdp.search_colors.placeholder")
    }
    enum ShareProduct {
      enum From {
        /// from Alfie
        static let subject = L10n.tr("L10n", "pdp.share_product.from.subject")
      }
    }
    enum TabControl {
      enum DescriptionOption {
        /// Description
        static let title = L10n.tr("L10n", "pdp.tab_control.description_option.title")
      }
    }
  }
  enum Plp {
    enum ErrorView {
      /// Please try again later
      static let message = L10n.tr("L10n", "plp.error_view.message")
      /// Cannot load products
      static let title = L10n.tr("L10n", "plp.error_view.title")
    }
    enum ListStyle {
      enum Option {
        /// Page Style
        static let title = L10n.tr("L10n", "plp.list_style.option.title")
      }
    }
    enum NumberOfResults {
      /// Plural format key: plp.number_of_results.message
      static func message(_ p1: Int) -> String {
        return L10n.tr("L10n", "plp.number_of_results.message", p1)
      }
    }
    enum Refine {
      enum Button {
        /// Refine
        static let cta = L10n.tr("L10n", "plp.refine.button.cta")
      }
    }
    enum RefineAndSort {
      /// Refine and Sort
      static let title = L10n.tr("L10n", "plp.refine_and_sort.title")
    }
    enum ShowResults {
      enum Button {
        /// Show results
        static let cta = L10n.tr("L10n", "plp.show_results.button.cta")
      }
    }
    enum SortBy {
      enum Option {
        /// Sort By
        static let title = L10n.tr("L10n", "plp.sort_by.option.title")
      }
    }
  }
  enum Product {
    enum AddToBag {
      enum Button {
        /// Add to bag
        static let cta = L10n.tr("L10n", "product.add_to_bag.button.cta")
      }
    }
    enum AddToWishlist {
      enum Button {
        /// Add to wishlist
        static let cta = L10n.tr("L10n", "product.add_to_wishlist.button.cta")
      }
    }
    enum Color {
      /// Colour
      static let title = L10n.tr("L10n", "product.color.title")
    }
    enum OneSize {
      /// One Size
      static let title = L10n.tr("L10n", "product.one_size.title")
    }
    enum OutOfStock {
      enum Button {
        /// Out of Stock
        static let cta = L10n.tr("L10n", "product.out_of_stock.button.cta")
      }
    }
    enum Size {
      /// Size
      static let title = L10n.tr("L10n", "product.size.title")
    }
  }
  enum Search {
    enum Screen {
      enum EmptyView {
        /// Search for designers, categories and products
        static let message = L10n.tr("L10n", "search.screen.empty_view.message")
        /// Find what you're looking for
        static let title = L10n.tr("L10n", "search.screen.empty_view.title")
      }
      enum NoResultsView {
        /// View all brands sold at Alfie
        static let link = L10n.tr("L10n", "search.screen.no_results_view.link")
        /// Please check that you have typed the word correctly or broaden your search term.
        static let message = L10n.tr("L10n", "search.screen.no_results_view.message")
        /// We were unable to find any results for your search ‘%@’
        static func term(_ p1: Any) -> String {
          return L10n.tr("L10n", "search.screen.no_results_view.term", String(describing: p1))
        }
      }
      enum RecentSearches {
        enum ClearAll {
          enum Button {
            /// Clear
            static let cta = L10n.tr("L10n", "search.screen.recent_searches.clear_all.button.cta")
          }
        }
        enum Header {
          /// Your Recent Searches
          static let title = L10n.tr("L10n", "search.screen.recent_searches.header.title")
        }
      }
      enum Suggestions {
        enum More {
          enum Button {
            /// More Products
            static let cta = L10n.tr("L10n", "search.screen.suggestions.more.button.cta")
          }
        }
      }
      enum SuggestionsBrands {
        enum Header {
          /// Brand
          static let title = L10n.tr("L10n", "search.screen.suggestions_brands.header.title")
        }
      }
      enum SuggestionsProducts {
        enum Header {
          /// Product Suggestions
          static let title = L10n.tr("L10n", "search.screen.suggestions_products.header.title")
        }
      }
      enum SuggestionsTerms {
        enum Header {
          /// Search Suggestions
          static let title = L10n.tr("L10n", "search.screen.suggestions_terms.header.title")
        }
      }
    }
  }
  enum SearchBar {
    /// Cancel
    static let cancel = L10n.tr("L10n", "search_bar.cancel")
    /// Search Alfie
    static let placeholder = L10n.tr("L10n", "search_bar.placeholder")
    enum Focused {
      /// What are you looking for?
      static let placeholder = L10n.tr("L10n", "search_bar.focused.placeholder")
    }
  }
  enum Shop {
    /// Shop
    static let title = L10n.tr("L10n", "shop.title")
    enum Brands {
      enum ErrorView {
        /// Please try again later
        static let message = L10n.tr("L10n", "shop.brands.error_view.message")
        /// Cannot load Brands list
        static let title = L10n.tr("L10n", "shop.brands.error_view.title")
      }
      enum SearchBar {
        /// Sorry, no results were found for
        static let noResultsMessage = L10n.tr("L10n", "shop.brands.search_bar.no_results_message")
        /// Search Brands
        static let placeholder = L10n.tr("L10n", "shop.brands.search_bar.placeholder")
      }
      enum Segment {
        /// Brands
        static let title = L10n.tr("L10n", "shop.brands.segment.title")
      }
    }
    enum Categories {
      enum ErrorView {
        /// Please try again later
        static let message = L10n.tr("L10n", "shop.categories.error_view.message")
        /// Cannot load categories
        static let title = L10n.tr("L10n", "shop.categories.error_view.title")
      }
      enum Segment {
        /// Categories
        static let title = L10n.tr("L10n", "shop.categories.segment.title")
      }
    }
    enum Services {
      enum Segment {
        /// Services
        static let title = L10n.tr("L10n", "shop.services.segment.title")
      }
    }
  }
  enum SortBy {
    enum AlphaAsc {
      /// A-Z
      static let title = L10n.tr("L10n", "sort_by.alpha_asc.title")
    }
    enum AlphaDesc {
      /// Z-A
      static let title = L10n.tr("L10n", "sort_by.alpha_desc.title")
    }
    enum MostPopular {
      /// Most Popular
      static let title = L10n.tr("L10n", "sort_by.most_popular.title")
    }
    enum PriceHighToLow {
      /// Price-High to Low
      static let title = L10n.tr("L10n", "sort_by.price_high_to_low.title")
    }
    enum PriceLowToHigh {
      /// Price - Low to High
      static let title = L10n.tr("L10n", "sort_by.price_low_to_high.title")
    }
  }
  enum Tab {
    enum Bag {
      /// Bag
      static let title = L10n.tr("L10n", "tab.bag.title")
    }
    enum Home {
      /// Home
      static let title = L10n.tr("L10n", "tab.home.title")
    }
    enum Shop {
      /// Shop
      static let title = L10n.tr("L10n", "tab.shop.title")
    }
    enum Wishlist {
      /// Wishlist
      static let title = L10n.tr("L10n", "tab.wishlist.title")
    }
  }
  enum WebView {
    enum ErrorView {
      /// Oops!
      static let title = L10n.tr("L10n", "web_view.error_view.title")
      enum Button {
        /// Retry
        static let cta = L10n.tr("L10n", "web_view.error_view.button.cta")
      }
      enum Generic {
        /// Something went wrong.
        static let message = L10n.tr("L10n", "web_view.error_view.generic.message")
      }
    }
    enum PaymentOptionsFeature {
      /// Payment Options
      static let title = L10n.tr("L10n", "web_view.payment_options_feature.title")
    }
    enum ReturnOptionsFeature {
      /// Returns Information
      static let title = L10n.tr("L10n", "web_view.return_options_feature.title")
    }
    enum StoreServicesFeature {
      /// Store & Services
      static let title = L10n.tr("L10n", "web_view.store_services_feature.title")
    }
  }
  enum Wishlist {
    /// Wishlist
    static let title = L10n.tr("L10n", "wishlist.title")
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

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}

#if DEBUG

// MARK: - Testable Keys

extension L10n {
  enum Keys: String, RawRepresentable, CaseIterable {

      case accountTitle = "account.title"
      case bagTitle = "bag.title"
      case featureToggleTitle = "feature_toggle.title"
      case featureToggleAppUpdateOptionTitle = "feature_toggle.app_update.option.title"
      case featureToggleDebugConfigurationOptionTitle = "feature_toggle.debug_configuration.option.title"
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

