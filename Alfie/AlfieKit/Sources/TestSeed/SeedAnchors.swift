// swiftlint:disable type_name

/// Mirrors `SEED_ANCHORS` in Alfie-BFF `src/mock/fixtures/seed-anchors.ts`, key names unchanged.
/// Tests pin to these values and nothing else in the Mock BFF catalogue.
public enum SeedAnchors {
    public static let menuHandle = "main-menu"

    public enum collections {
        public static let women = "women"
        public static let men = "men"
        public static let shirts = "shirts"
        public static let dresses = "dresses"
        public static let sale = "sale"
    }

    public enum brandKeys {
        public static let alfie = "alfie"
        public static let northwind = "northwind"
        public static let harbour = "harbour"
        public static let ember = "ember"
    }

    public enum products {
        public static let `default` = "alfie-oxford-shirt"
        public static let allAccordionMetafields = "alfie-oxford-shirt"
        public static let outOfStock = "harbour-cashmere-crew-jumper"
        public static let singleVariant = "ember-silk-square-scarf"
        public static let onSale = "northwind-linen-wrap-dress"
        public static let longName = "alfie-relaxed-organic-cotton-twill-utility-overshirt"
        public static let noBrand = "essential-crew-neck-tee"
        public static let oneImage = "harbour-pleated-midi-skirt"
        public static let noMetafieldsNoSizeGuide = "ember-waxed-field-jacket"
    }

    public enum searchTerms {
        public static let many = "shirt"
        public static let few = "dress"
        // swiftlint:disable:next discouraged_none_name
        public static let none = "zzz-no-results"
    }

    public enum barcode {
        public static let value = "2000001000007"
        public static let productSlug = "alfie-oxford-shirt"
        public static let variantId = "mock-variant-alfie-oxford-shirt-white-xs"
    }

    public static let unknownBarcode = "0000000000000"

    public static let relatedProductSlugs = [
        "alfie-poplin-shirt",
        "alfie-linen-camp-shirt",
        "alfie-satin-slip-dress",
        "northwind-wide-leg-trousers",
        "ember-cropped-cardigan",
        "alfie-oxford-button-down-shirt",
        "alfie-slim-chinos",
        "alfie-harrington-jacket",
    ]

    public enum timestamps {
        public static let defaultProductCreatedAt = "2025-03-03T09:30:00Z"
        public static let defaultProductUpdatedAt = "2026-02-10T10:30:00Z"
    }
}

// swiftlint:enable type_name
