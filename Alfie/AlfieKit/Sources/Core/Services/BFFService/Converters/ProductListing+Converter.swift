import BFFGraph
import Foundation
import Model
import Utils

extension BFFGraphAPI.ProductListQuery.Data.ProductList {
    public func convertToProductListing() -> ProductListing {
        // ALFMOB-331 AC 1: minimal mapping from the new productList response.
        // Cursor pagination, totalCount surfacing and the slimmer Product model will be
        // wired in ACs 2 & 5; for now we keep the existing Pagination shape populated
        // with sensible defaults so the screen can render.
        let mappedProducts = products.map { $0.fragments.productListItemFragment.convertToProduct() }
        let pagination = ProductListing.Pagination(
            offset: 0,
            limit: mappedProducts.count,
            total: totalCount ?? mappedProducts.count,
            pages: pageInfo?.hasNextPage == true ? 2 : 1,
            page: 1,
            nextPage: nil,
            previousPage: nil
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

        let placeholderVariant = Product.Variant(
            sku: "",
            size: nil,
            colour: nil,
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
            colours: nil
        )
    }
}

extension BFFGraphAPI.MoneyFragment {
    func toDomainMoney() -> Money {
        // BFF Money.amount is major-units Float; the domain model stores minor units (Int)
        // plus a locale-formatted string. The proper formatter lives in a follow-up;
        // for AC 1 we round to minor units and format with the currency code.
        let minorUnits = Int((amount * 100).rounded())
        return Money(
            currencyCode: currencyCode,
            amount: minorUnits,
            amountFormatted: String(format: "%.2f %@", amount, currencyCode)
        )
    }
}
