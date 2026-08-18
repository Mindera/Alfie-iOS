/// Centralised registry of accessibility identifiers used across the app and
/// consumed by UI tests. Identifiers follow the convention:
///
///     screen.component[.subcomponent].type
///
/// Use static constants for fixed elements and pure functions for dynamic ones
/// (always derived from a stable model id, never from an array index).
public enum AccessibilityID {

    // MARK: - Brands

    public enum Brands {
        public static let item = "brands.item.button"
    }

    // MARK: - Categories

    public enum Categories {
        public static let retryButton = "categories.retry.button"
    }

    // MARK: - Shop

    public enum Shop {
        public static let searchInput = "shop.search.input"
    }

    // MARK: - Splash

    public enum Splash {
        public static let screen = "splash.screen"
    }

    // MARK: - TabBar

    public enum TabBar {
        public static let home = "home-tab"
        public static let shop = "shop-tab"
        public static let bag = "bag-tab"
        public static let wishlist = "wishlist-tab"
        public static let account = "account-tab"
    }

    // MARK: - ProductDetails

    public enum ProductDetails {
        public static let titleHeader = "productDetails.title.header"
        public static let productImage = "productDetails.product.image"
        /// The brand line above the product name — this is the view model's `productTitle`. The
        /// in-body product name is `productName`, which used to carry the `productTitle` identifier.
        public static let brandName = "productDetails.brand.name"
        public static let productName = "productDetails.product.name"
        public static let productDescription = "productDetails.description.text"
        /// The inline card grid. Present only for a short colour run — a long one uses the summary,
        /// or `colourSheetRow` when nothing is selected yet.
        public static let colourSelector = "productDetails.colour.selector"
        public static let colourSheetRow = "productDetails.colour.sheetRow"
        public static let colourSummary = "productDetails.colour.summary"
        public static let sizeSelector = "productDetails.size.selector"
        /// Drawn by the design with no destination behind it — rendered, but not interactive.
        public static let sizeGuideLink = "productDetails.sizeGuide.link"
        public static let addToBagButton = "productDetails.addToBag.button"
        public static let addToWishlistButton = "productDetails.addToWishlist.button"
    }

    // MARK: - ProductListing

    public enum ProductListing {
        public static let screen = "productListing"
        public static let filterButton = "productListing.filter.button"
        public static let resultsLabel = "productListing.results.label"
        public static let listStyleGridButton = "productListing.listStyle.grid.button"
        public static let listStyleListButton = "productListing.listStyle.list.button"
        public static let retryButton = "productListing.retry.button"

        /// Returns a row-scoped prefix for composing element identifiers within a listing row.
        /// Append a type suffix for specific elements: `row(id:) + ".image"`, `row(id:) + ".button"`, etc.
        public static func row(id: String) -> String {
            "productListing.row.\(id)"
        }
    }

    // MARK: - Home

    public enum Home {
        public static let titleHeader = "home.title.header"
        public static let searchInput = "home.search.input"
    }

    // MARK: - Account

    public enum Account {
        public static let settingsSection = "account.settings.section"
    }
}
