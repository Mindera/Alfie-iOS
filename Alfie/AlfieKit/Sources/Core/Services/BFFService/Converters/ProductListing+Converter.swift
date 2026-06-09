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
    func toDomainMoney() -> Money {
        // BFF amount is a major-unit Double; parse once to a clean Decimal to avoid binary-float
        // noise, then derive both the integer minor-unit amount and the locale-formatted string.
        // Guard non-finite input (NaN/±inf) — Decimal(inf) traps and Decimal(nan) overflows on scaling.
        let decimal = amount.isFinite ? (Decimal(string: String(amount)) ?? Decimal(amount)) : .zero
        return Money(
            currencyCode: currencyCode,
            amount: CurrencyFormatter.minorUnits(of: decimal, currencyCode: currencyCode),
            amountFormatted: CurrencyFormatter.string(amount: decimal, currencyCode: currencyCode)
        )
    }
}
