import BFFGraph
import Foundation
import Model
import Utils

extension BFFGraphAPI.ProductListQuery.Data.ProductList {
    public func convertToProductListing() -> ProductListing {
        let mappedProducts = products.map { $0.fragments.productListItemFragment.convertToProduct() }
        let pagination = ProductListing.Pagination(
            totalCount: totalCount,
            endCursor: pageInfo?.endCursor,
            hasNextPage: pageInfo?.hasNextPage ?? false
        )
        return ProductListing(
            title: "",
            pagination: pagination,
            products: mappedProducts
        )
    }
}

extension BFFGraphAPI.SearchProductsQuery.Data.SearchProducts {
    public func convertToProductListing() -> ProductListing {
        let mappedProducts = products.map { $0.fragments.productListItemFragment.convertToProduct() }
        let pagination = ProductListing.Pagination(
            totalCount: totalCount,
            endCursor: pageInfo?.endCursor,
            hasNextPage: pageInfo?.hasNextPage ?? false
        )
        return ProductListing(
            title: "",
            pagination: pagination,
            products: mappedProducts
        )
    }
}

extension BFFGraphAPI.ProductListItemFragment {
    func convertToProduct() -> Product {
        let lowMoney = priceRange.minVariantPrice.fragments.moneyFragment.toDomainMoney()
        let highMoneyRaw = priceRange.maxVariantPrice.fragments.moneyFragment.toDomainMoney()
        let highMoney: Money? = highMoneyRaw == lowMoney ? nil : highMoneyRaw

        // The list-item shape gives us a single `primaryImage` per product (no colour
        // variants from the BFF yet). Wrap it in a synthetic `Product.Colour` so the
        // existing card view models — which read `defaultVariant.media.first` via
        // `colour?.media` — pick the image up. When the BFF starts returning per-colour
        // media this can be swapped for a real mapping.
        let colour: Product.Colour? = primaryImage.flatMap { image in
            guard let url = URL(string: image.url) else { return nil }
            return Product.Colour(
                swatch: nil,
                name: "",
                media: [.image(MediaImage(alt: image.altText, mediaContentType: .image, url: url))]
            )
        }

        let placeholderVariant = Product.Variant(
            sku: "",
            size: nil,
            colour: colour,
            attributes: nil,
            stock: inventoryTotal ?? 0,
            price: Price(amount: lowMoney, was: nil)
        )

        return Product(
            id: id,
            styleNumber: "",
            name: name,
            brand: Brand(name: brandName ?? "", slug: ""),
            shortDescription: "",
            longDescription: descriptionHtml,
            slug: slug,
            priceRange: Model.PriceRange(low: lowMoney, high: highMoney),
            attributes: nil,
            defaultVariant: placeholderVariant,
            variants: [],
            colours: colour.map { [$0] }
        )
    }
}

extension BFFGraphAPI.MoneyFragment {
    /// The amount as a `Decimal`, or `nil` where the BFF sent one this app cannot represent.
    ///
    /// Both tests are load-bearing, because each one misses what the other catches, and both inputs
    /// are reachable from *legal* JSON — Apollo deserialises with `JSONSerialization`, which has no
    /// `NaN` or `Infinity` literal but still overflows a large exponent into one:
    ///
    /// - `-1e400` parses to `-inf`. `Decimal(string: "-inf")` returns **0**, not `nil`, so without
    ///   the `isFinite` test an infinite amount would quietly become £0.00.
    /// - `1e300` is finite, so `isFinite` passes it, but it is outside `Decimal`'s range (the limit
    ///   sits between `1e120` and `1e140`) and `Decimal(string:)` returns `nil`.
    ///
    /// Parsed via the string form rather than `Decimal(_: Double)` to avoid binary-float noise.
    private var decimalAmount: Decimal? {
        guard amount.isFinite else { return nil }
        return Decimal(string: String(amount))
    }

    func toDomainMoney() -> Money {
        // BFF amount is a major-unit Double; parse once to a clean Decimal, then derive both the
        // minor-unit amount and the formatted string. An unrepresentable amount falls back to zero,
        // which Q36 keeps for listings — the bag uses `toDomainMoneyIfRenderable()` instead.
        makeMoney(decimalAmount ?? .zero)
    }

    /// `toDomainMoney()` without its zero fallback: `nil` where the amount cannot be represented, so
    /// a caller that must not print a price the shopper does not owe can say "unknown" instead.
    func toDomainMoneyIfRenderable() -> Money? {
        decimalAmount.map(makeMoney)
    }

    private func makeMoney(_ decimal: Decimal) -> Money {
        Money(
            currencyCode: currencyCode,
            amount: CurrencyFormatter.minorUnits(of: decimal, currencyCode: currencyCode),
            amountFormatted: CurrencyFormatter.string(amount: decimal, currencyCode: currencyCode)
        )
    }
}
