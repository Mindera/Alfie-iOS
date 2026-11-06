/// The subset of `SEED_ANCHORS` (Alfie-BFF `src/mock/fixtures/seed-anchors.ts`) that tests pin to.
/// Values are copied verbatim; add an anchor here when a test needs it.
public enum SeedAnchors {
    public enum Collections {
        public static let women = "women"
    }

    public enum Products {
        /// Multi-variant, with a multi-image gallery.
        public static let `default` = "alfie-oxford-shirt"
    }

    public enum SearchTerms {
        /// Matches more than 10 products.
        public static let many = "shirt"
    }

    public enum Barcode {
        public static let value = "2000001000007"
    }

    /// A valid EAN-13 that no fixture carries.
    public static let unknownBarcode = "0000000000000"
}
