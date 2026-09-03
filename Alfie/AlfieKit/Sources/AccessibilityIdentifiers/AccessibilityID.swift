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
        /// The `<colour> | Ref. <sku>` line beneath the description.
        public static let descriptionMetadata = "productDetails.description.metadata"
        /// The inline card grid, present whenever the product has more than one colour.
        public static let colourSelector = "productDetails.colour.selector"
        public static let colourSummary = "productDetails.colour.summary"
        public static let sizeSelector = "productDetails.size.selector"
        /// Drawn by the design with no destination behind it — rendered, but not interactive.
        public static let sizeGuideLink = "productDetails.sizeGuide.link"
        public static let addToBagButton = "productDetails.addToBag.button"
        public static let addToWishlistButton = "productDetails.addToWishlist.button"
    }

    // MARK: - Snackbar

    /// The transient feedback banner, shared by every screen that presents one. Matching on it by
    /// identifier keeps UI tests off the user-facing copy, which is localised and changes freely.
    public enum Snackbar {
        public static let view = "snackbar.view"
        public static let text = "snackbar.text"
    }

    // MARK: - ProductListing

    public enum ProductListing {
        public static let screen = "productListing"
        public static let filterButton = "productListing.filter.button"
        public static let resultsLabel = "productListing.results.label"
        public static let listStyleGridButton = "productListing.listStyle.grid.button"
        public static let listStyleListButton = "productListing.listStyle.list.button"
        public static let retryButton = "productListing.retry.button"
        public static let filterChips = "productListing.filterChips"
        public static func filterChip(index: Int) -> String { "productListing.filterChip.\(index).button" }

        // MARK: Refine sheet

        public static let refineSheet = "productListing.refine.sheet"
        public static let refineCloseButton = "productListing.refine.close.button"
        public static let refineRemoveAllButton = "productListing.refine.removeAll.button"
        /// The sub-screen header's Remove All. Same behaviour as the panel's, but a distinct id —
        /// both are in the hierarchy while a sub-screen is pushed.
        public static let refineSubscreenRemoveAllButton = "productListing.refine.subscreen.removeAll.button"
        public static let refineApplyButton = "productListing.refine.apply.button"
        public static let refineBackButton = "productListing.refine.back.button"
        public static let refinePriceRow = "productListing.refine.price.row"
        public static let refineSortRow = "productListing.refine.sort.row"
        public static let refinePriceMinInput = "productListing.refine.price.min.input"
        public static let refinePriceMaxInput = "productListing.refine.price.max.input"
        public static let refinePriceError = "productListing.refine.price.error"

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
