import Model

extension VariantSelection {
    /// A freshly fetched product, with the shopper's requested variant restored when it still exists.
    ///
    /// When re-entering from Bag/Wishlist (`.selectedProduct`) the persisted variant carries a stale
    /// snapshot (e.g. out-of-date stock), so map the shopper's choice onto the freshly fetched
    /// product by `sku` — keeping what they chose while reflecting current stock and price. A deep
    /// link's `sku` (a scanned Alfie code) is mapped the same way, then a scanned Barcode's
    /// `variantId`. When nothing was requested, or the product no longer offers it, the fresh-open
    /// path seeds the colour from merchandising.
    init(product: Product, restoringSku sku: String?, orVariantId variantId: String?) {
        guard let restored = Self.variant(in: product, sku: sku, variantId: variantId) else {
            self.init(variants: product.variants, preferredVariant: product.defaultVariant)
            return
        }
        self.init(variants: product.variants, restoring: restored)
    }

    private static func variant(in product: Product, sku: String?, variantId: String?) -> Product.Variant? {
        if let sku, let variant = product.variants.first(where: { $0.sku == sku }) {
            return variant
        }
        if let variantId, let variant = product.variants.first(where: { $0.id == variantId }) {
            return variant
        }
        return nil
    }
}
