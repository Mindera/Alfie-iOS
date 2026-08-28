// ⚠️ This file is automatically updated by SwiftGen - Do not modify ⚠️ — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - Strings

public enum L10n {
  public enum Accessibility {
    /// Account
    public static let account = L10n.tr("L10n", "accessibility.account")
    /// Back
    public static let back = L10n.tr("L10n", "accessibility.back")
    /// Clear search
    public static let clearSearch = L10n.tr("L10n", "accessibility.clearSearch")
    /// Close
    public static let close = L10n.tr("L10n", "accessibility.close")
    /// Grid view
    public static let gridView = L10n.tr("L10n", "accessibility.gridView")
    /// List view
    public static let listView = L10n.tr("L10n", "accessibility.listView")
    /// Menu
    public static let menu = L10n.tr("L10n", "accessibility.menu")
    /// Next page
    public static let nextPage = L10n.tr("L10n", "accessibility.nextPage")
    /// Previous page
    public static let previousPage = L10n.tr("L10n", "accessibility.previousPage")
    /// Remove from wishlist
    public static let removeFromWishlist = L10n.tr("L10n", "accessibility.removeFromWishlist")
    /// Remove recent search
    public static let removeRecentSearch = L10n.tr("L10n", "accessibility.removeRecentSearch")
    /// Search
    public static let search = L10n.tr("L10n", "accessibility.search")
    /// Settings
    public static let settings = L10n.tr("L10n", "accessibility.settings")
    /// Share
    public static let share = L10n.tr("L10n", "accessibility.share")
    /// Wishlist
    public static let wishlist = L10n.tr("L10n", "accessibility.wishlist")
  }
  public enum Account {
    /// Settings
    public static let settings = L10n.tr("L10n", "account.settings")
    /// Account
    public static let title = L10n.tr("L10n", "account.title")
  }
  public enum Bag {
    /// Bag
    public static let title = L10n.tr("L10n", "bag.title")
    public enum Empty {
      /// Items you add to your bag will appear here
      public static let message = L10n.tr("L10n", "bag.empty.message")
      /// Your bag is empty
      public static let title = L10n.tr("L10n", "bag.empty.title")
    }
    public enum ErrorView {
      /// Something went wrong
      public static let title = L10n.tr("L10n", "bag.error_view.title")
      public enum Generic {
        /// Please try again later
        public static let message = L10n.tr("L10n", "bag.error_view.generic.message")
      }
      public enum NoInternet {
        /// Check your connection and try again
        public static let message = L10n.tr("L10n", "bag.error_view.no_internet.message")
        /// No connection
        public static let title = L10n.tr("L10n", "bag.error_view.no_internet.title")
      }
      public enum Retry {
        /// Retry
        public static let cta = L10n.tr("L10n", "bag.error_view.retry.cta")
      }
    }
    public enum LineTotal {
      /// —
      public static let unavailable = L10n.tr("L10n", "bag.line_total.unavailable")
    }
    public enum Quantity {
      /// Qty: %d
      public static func label(_ p1: Int) -> String {
        return L10n.tr("L10n", "bag.quantity.label", p1)
      }
    }
    public enum Remove {
      /// Remove
      public static let cta = L10n.tr("L10n", "bag.remove.cta")
    }
    public enum Subtotal {
      /// Subtotal
      public static let title = L10n.tr("L10n", "bag.subtotal.title")
    }
    public enum Total {
      /// Total
      public static let title = L10n.tr("L10n", "bag.total.title")
    }
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
  public enum General {
    public enum Done {
      /// Done
      public static let cta = L10n.tr("L10n", "general.done.cta")
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
      /// What are you looking for?
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
    public enum Colour {
      public enum OutOfStock {
        /// Out of stock
        public static let accessibilityValue = L10n.tr("L10n", "pdp.colour.out_of_stock.accessibility_value")
      }
    }
    public enum ColourSelector {
      /// Select a Colour
      public static let title = L10n.tr("L10n", "pdp.colour_selector.title")
    }
    public enum ColourSummary {
      /// Opens colour selection
      public static let accessibilityHint = L10n.tr("L10n", "pdp.colour_summary.accessibility_hint")
      /// Plural format key: pdp.colour_summary.accessibility_label
      public static func accessibilityLabel(_ p1: Any, _ p2: Int) -> String {
        return L10n.tr("L10n", "pdp.colour_summary.accessibility_label", String(describing: p1), p2)
      }
      /// +%d
      public static func count(_ p1: Int) -> String {
        return L10n.tr("L10n", "pdp.colour_summary.count", p1)
      }
    }
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
    public enum DescriptionMetadata {
      /// %1$@, Ref. %2$@
      public static func accessibilityLabel(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("L10n", "pdp.description_metadata.accessibility_label", String(describing: p1), String(describing: p2))
      }
      /// %1$@ | Ref. %2$@
      public static func colourAndReference(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("L10n", "pdp.description_metadata.colour_and_reference", String(describing: p1), String(describing: p2))
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
      public enum RateLimited {
        /// Please wait a moment and try again.
        public static let message = L10n.tr("L10n", "pdp.error_view.rate_limited.message")
        /// Too many requests
        public static let title = L10n.tr("L10n", "pdp.error_view.rate_limited.title")
      }
      public enum ServerError {
        /// We're having trouble reaching our servers. Please try again.
        public static let message = L10n.tr("L10n", "pdp.error_view.server_error.message")
        /// Service unavailable
        public static let title = L10n.tr("L10n", "pdp.error_view.server_error.title")
      }
    }
    public enum Gallery {
      /// Opens full screen
      public static let accessibilityHint = L10n.tr("L10n", "pdp.gallery.accessibility_hint")
      /// Product images
      public static let accessibilityLabel = L10n.tr("L10n", "pdp.gallery.accessibility_label")
      /// Image %1$d of %2$d
      public static func accessibilityValue(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("L10n", "pdp.gallery.accessibility_value", p1, p2)
      }
    }
    public enum ProductReference {
      /// Ref. %@
      public static func value(_ p1: Any) -> String {
        return L10n.tr("L10n", "pdp.product_reference.value", String(describing: p1))
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
    public enum SizeGuide {
      /// Size Guide
      public static let link = L10n.tr("L10n", "pdp.size_guide.link")
    }
    public enum SizeSelector {
      /// Select Your Size
      public static let title = L10n.tr("L10n", "pdp.size_selector.title")
    }
  }
  public enum Plp {
    public enum ErrorView {
      /// Please try again later
      public static let message = L10n.tr("L10n", "plp.error_view.message")
      /// Cannot load products
      public static let title = L10n.tr("L10n", "plp.error_view.title")
      public enum Button {
        /// Retry
        public static let cta = L10n.tr("L10n", "plp.error_view.button.cta")
      }
      public enum RateLimited {
        /// Please wait a moment and try again.
        public static let message = L10n.tr("L10n", "plp.error_view.rate_limited.message")
        /// Too many requests
        public static let title = L10n.tr("L10n", "plp.error_view.rate_limited.title")
      }
      public enum ServerError {
        /// We're having trouble reaching our servers. Please try again.
        public static let message = L10n.tr("L10n", "plp.error_view.server_error.message")
        /// Service unavailable
        public static let title = L10n.tr("L10n", "plp.error_view.server_error.title")
      }
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
    public enum QuickFilter {
      public enum Cotton {
        /// Cotton
        public static let label = L10n.tr("L10n", "plp.quick_filter.cotton.label")
      }
      public enum Linen {
        /// Linen
        public static let label = L10n.tr("L10n", "plp.quick_filter.linen.label")
      }
      public enum RegularFit {
        /// Regular Fit
        public static let label = L10n.tr("L10n", "plp.quick_filter.regular_fit.label")
      }
      public enum Silk {
        /// Silk
        public static let label = L10n.tr("L10n", "plp.quick_filter.silk.label")
      }
      public enum SlimFit {
        /// Slim Fit
        public static let label = L10n.tr("L10n", "plp.quick_filter.slim_fit.label")
      }
      public enum StraightFit {
        /// Straight Fit
        public static let label = L10n.tr("L10n", "plp.quick_filter.straight_fit.label")
      }
      public enum Wool {
        /// Wool
        public static let label = L10n.tr("L10n", "plp.quick_filter.wool.label")
      }
    }
    public enum Refine {
      public enum Button {
        /// Refine
        public static let cta = L10n.tr("L10n", "plp.refine.button.cta")
      }
      public enum Price {
        public enum InvalidRange {
          /// The minimum must be lower than the maximum.
          public static let message = L10n.tr("L10n", "plp.refine.price.invalid_range.message")
        }
        public enum Max {
          /// Max
          public static let label = L10n.tr("L10n", "plp.refine.price.max.label")
        }
        public enum Min {
          /// Min
          public static let label = L10n.tr("L10n", "plp.refine.price.min.label")
        }
        public enum NoMaximum {
          /// No maximum
          public static let accessibilityValue = L10n.tr("L10n", "plp.refine.price.no_maximum.accessibility_value")
        }
        public enum NoMinimum {
          /// No minimum
          public static let accessibilityValue = L10n.tr("L10n", "plp.refine.price.no_minimum.accessibility_value")
        }
        public enum Option {
          /// Price
          public static let title = L10n.tr("L10n", "plp.refine.price.option.title")
        }
        public enum Summary {
          /// %1$@ – %2$@
          public static func between(_ p1: Any, _ p2: Any) -> String {
            return L10n.tr("L10n", "plp.refine.price.summary.between", String(describing: p1), String(describing: p2))
          }
          /// %@ and up
          public static func from(_ p1: Any) -> String {
            return L10n.tr("L10n", "plp.refine.price.summary.from", String(describing: p1))
          }
          /// Up to %@
          public static func upTo(_ p1: Any) -> String {
            return L10n.tr("L10n", "plp.refine.price.summary.up_to", String(describing: p1))
          }
        }
      }
      public enum RemoveAll {
        public enum Button {
          /// Remove All
          public static let cta = L10n.tr("L10n", "plp.refine.remove_all.button.cta")
        }
      }
    }
    public enum RefineAndSort {
      /// Refine and Sort
      public static let title = L10n.tr("L10n", "plp.refine_and_sort.title")
    }
    public enum Refresh {
      /// Couldn't refresh. Please try again.
      public static let errorMessage = L10n.tr("L10n", "plp.refresh.error_message")
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
      public enum Error {
        /// Couldn't add to bag
        public static let message = L10n.tr("L10n", "product.add_to_bag.error.message")
      }
      public enum Success {
        /// Added to bag
        public static let message = L10n.tr("L10n", "product.add_to_bag.success.message")
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
      /// Size: %@
      public static func selected(_ p1: Any) -> String {
        return L10n.tr("L10n", "product.size.selected", String(describing: p1))
      }
      /// Size
      public static let title = L10n.tr("L10n", "product.size.title")
      public enum OutOfStock {
        /// Out of stock
        public static let accessibilityValue = L10n.tr("L10n", "product.size.out_of_stock.accessibility_value")
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
    public enum Categories {
      public enum ErrorView {
        /// Please try again later
        public static let message = L10n.tr("L10n", "shop.categories.error_view.message")
        /// Cannot load categories
        public static let title = L10n.tr("L10n", "shop.categories.error_view.title")
        public enum Button {
          /// Retry
          public static let cta = L10n.tr("L10n", "shop.categories.error_view.button.cta")
        }
        public enum RateLimited {
          /// Please wait a moment and try again.
          public static let message = L10n.tr("L10n", "shop.categories.error_view.rate_limited.message")
          /// Too many requests
          public static let title = L10n.tr("L10n", "shop.categories.error_view.rate_limited.title")
        }
        public enum ServerError {
          /// We're having trouble reaching our servers. Please try again.
          public static let message = L10n.tr("L10n", "shop.categories.error_view.server_error.message")
          /// Service unavailable
          public static let title = L10n.tr("L10n", "shop.categories.error_view.server_error.title")
        }
      }
      public enum Segment {
        /// Categories
        public static let title = L10n.tr("L10n", "shop.categories.segment.title")
      }
    }
  }
  public enum SortBy {
    public enum AlphaAsc {
      /// A-Z
      public static let title = L10n.tr("L10n", "sort_by.alpha_asc.title")
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

      case accessibilityAccount = "accessibility.account"
      case accessibilityBack = "accessibility.back"
      case accessibilityClearSearch = "accessibility.clearSearch"
      case accessibilityClose = "accessibility.close"
      case accessibilityGridView = "accessibility.gridView"
      case accessibilityListView = "accessibility.listView"
      case accessibilityMenu = "accessibility.menu"
      case accessibilityNextPage = "accessibility.nextPage"
      case accessibilityPreviousPage = "accessibility.previousPage"
      case accessibilityRemoveFromWishlist = "accessibility.removeFromWishlist"
      case accessibilityRemoveRecentSearch = "accessibility.removeRecentSearch"
      case accessibilitySearch = "accessibility.search"
      case accessibilitySettings = "accessibility.settings"
      case accessibilityShare = "accessibility.share"
      case accessibilityWishlist = "accessibility.wishlist"
      case accountSettings = "account.settings"
      case accountTitle = "account.title"
      case bagTitle = "bag.title"
      case bagEmptyMessage = "bag.empty.message"
      case bagEmptyTitle = "bag.empty.title"
      case bagErrorViewTitle = "bag.error_view.title"
      case bagErrorViewGenericMessage = "bag.error_view.generic.message"
      case bagErrorViewNoInternetMessage = "bag.error_view.no_internet.message"
      case bagErrorViewNoInternetTitle = "bag.error_view.no_internet.title"
      case bagErrorViewRetryCta = "bag.error_view.retry.cta"
      case bagLineTotalUnavailable = "bag.line_total.unavailable"
      case bagQuantityLabel = "bag.quantity.label"
      case bagRemoveCta = "bag.remove.cta"
      case bagSubtotalTitle = "bag.subtotal.title"
      case bagTotalTitle = "bag.total.title"
      case featureToggleTitle = "feature_toggle.title"
      case featureToggleAppUpdateOptionTitle = "feature_toggle.app_update.option.title"
      case featureToggleDebugConfigurationOptionTitle = "feature_toggle.debug_configuration.option.title"
      case featureToggleStoreServicesOptionTitle = "feature_toggle.store_services.option.title"
      case featureToggleWishlistOptionTitle = "feature_toggle.wishlist.option.title"
      case generalDoneCta = "general.done.cta"
      case homeTitle = "home.title"
      case homeLoggedInSubtitle = "home.logged_in.subtitle"
      case homeLoggedInTitle = "home.logged_in.title"
      case homeSearchBarPlaceholder = "home.search_bar.placeholder"
      case homeSignInButtonCta = "home.sign_in.button.cta"
      case homeSignOutButtonCta = "home.sign_out.button.cta"
      case loadingTitle = "loading.title"
      case pdpColourOutOfStockAccessibilityValue = "pdp.colour.out_of_stock.accessibility_value"
      case pdpColourSelectorTitle = "pdp.colour_selector.title"
      case pdpColourSummaryAccessibilityHint = "pdp.colour_summary.accessibility_hint"
      case pdpColourSummaryAccessibilityLabel = "pdp.colour_summary.accessibility_label"
      case pdpColourSummaryCount = "pdp.colour_summary.count"
      case pdpComplementaryInfoDeliveryTitle = "pdp.complementary_info.delivery.title"
      case pdpComplementaryInfoPaymentTitle = "pdp.complementary_info.payment.title"
      case pdpComplementaryInfoReturnsTitle = "pdp.complementary_info.returns.title"
      case pdpDescriptionMetadataAccessibilityLabel = "pdp.description_metadata.accessibility_label"
      case pdpDescriptionMetadataColourAndReference = "pdp.description_metadata.colour_and_reference"
      case pdpErrorViewTitle = "pdp.error_view.title"
      case pdpErrorViewGenericMessage = "pdp.error_view.generic.message"
      case pdpErrorViewGoBackButtonCta = "pdp.error_view.go_back.button.cta"
      case pdpErrorViewNotFoundMessage = "pdp.error_view.not_found.message"
      case pdpErrorViewRateLimitedMessage = "pdp.error_view.rate_limited.message"
      case pdpErrorViewRateLimitedTitle = "pdp.error_view.rate_limited.title"
      case pdpErrorViewServerErrorMessage = "pdp.error_view.server_error.message"
      case pdpErrorViewServerErrorTitle = "pdp.error_view.server_error.title"
      case pdpGalleryAccessibilityHint = "pdp.gallery.accessibility_hint"
      case pdpGalleryAccessibilityLabel = "pdp.gallery.accessibility_label"
      case pdpGalleryAccessibilityValue = "pdp.gallery.accessibility_value"
      case pdpProductReferenceValue = "pdp.product_reference.value"
      case pdpSearchColorsPlaceholder = "pdp.search_colors.placeholder"
      case pdpShareProductFromSubject = "pdp.share_product.from.subject"
      case pdpSizeGuideLink = "pdp.size_guide.link"
      case pdpSizeSelectorTitle = "pdp.size_selector.title"
      case plpErrorViewMessage = "plp.error_view.message"
      case plpErrorViewTitle = "plp.error_view.title"
      case plpErrorViewButtonCta = "plp.error_view.button.cta"
      case plpErrorViewRateLimitedMessage = "plp.error_view.rate_limited.message"
      case plpErrorViewRateLimitedTitle = "plp.error_view.rate_limited.title"
      case plpErrorViewServerErrorMessage = "plp.error_view.server_error.message"
      case plpErrorViewServerErrorTitle = "plp.error_view.server_error.title"
      case plpListStyleOptionTitle = "plp.list_style.option.title"
      case plpNumberOfResultsMessage = "plp.number_of_results.message"
      case plpQuickFilterCottonLabel = "plp.quick_filter.cotton.label"
      case plpQuickFilterLinenLabel = "plp.quick_filter.linen.label"
      case plpQuickFilterRegularFitLabel = "plp.quick_filter.regular_fit.label"
      case plpQuickFilterSilkLabel = "plp.quick_filter.silk.label"
      case plpQuickFilterSlimFitLabel = "plp.quick_filter.slim_fit.label"
      case plpQuickFilterStraightFitLabel = "plp.quick_filter.straight_fit.label"
      case plpQuickFilterWoolLabel = "plp.quick_filter.wool.label"
      case plpRefineButtonCta = "plp.refine.button.cta"
      case plpRefinePriceInvalidRangeMessage = "plp.refine.price.invalid_range.message"
      case plpRefinePriceMaxLabel = "plp.refine.price.max.label"
      case plpRefinePriceMinLabel = "plp.refine.price.min.label"
      case plpRefinePriceNoMaximumAccessibilityValue = "plp.refine.price.no_maximum.accessibility_value"
      case plpRefinePriceNoMinimumAccessibilityValue = "plp.refine.price.no_minimum.accessibility_value"
      case plpRefinePriceOptionTitle = "plp.refine.price.option.title"
      case plpRefinePriceSummaryBetween = "plp.refine.price.summary.between"
      case plpRefinePriceSummaryFrom = "plp.refine.price.summary.from"
      case plpRefinePriceSummaryUpTo = "plp.refine.price.summary.up_to"
      case plpRefineRemoveAllButtonCta = "plp.refine.remove_all.button.cta"
      case plpRefineAndSortTitle = "plp.refine_and_sort.title"
      case plpRefreshErrorMessage = "plp.refresh.error_message"
      case plpShowResultsButtonCta = "plp.show_results.button.cta"
      case plpSortByOptionTitle = "plp.sort_by.option.title"
      case productAddToBagButtonCta = "product.add_to_bag.button.cta"
      case productAddToBagErrorMessage = "product.add_to_bag.error.message"
      case productAddToBagSuccessMessage = "product.add_to_bag.success.message"
      case productAddToWishlistButtonCta = "product.add_to_wishlist.button.cta"
      case productColorTitle = "product.color.title"
      case productOneSizeTitle = "product.one_size.title"
      case productOutOfStockButtonCta = "product.out_of_stock.button.cta"
      case productSizeSelected = "product.size.selected"
      case productSizeTitle = "product.size.title"
      case productSizeOutOfStockAccessibilityValue = "product.size.out_of_stock.accessibility_value"
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
      case shopCategoriesErrorViewMessage = "shop.categories.error_view.message"
      case shopCategoriesErrorViewTitle = "shop.categories.error_view.title"
      case shopCategoriesErrorViewButtonCta = "shop.categories.error_view.button.cta"
      case shopCategoriesErrorViewRateLimitedMessage = "shop.categories.error_view.rate_limited.message"
      case shopCategoriesErrorViewRateLimitedTitle = "shop.categories.error_view.rate_limited.title"
      case shopCategoriesErrorViewServerErrorMessage = "shop.categories.error_view.server_error.message"
      case shopCategoriesErrorViewServerErrorTitle = "shop.categories.error_view.server_error.title"
      case shopCategoriesSegmentTitle = "shop.categories.segment.title"
      case sortByAlphaAscTitle = "sort_by.alpha_asc.title"
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

