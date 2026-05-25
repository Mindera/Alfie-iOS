import BFFGraph
import Foundation
import Model
import Utils

extension BFFGraphAPI.ProductListQuery.Data.ProductList {
    public func convertToProductListing() -> ProductListing {
        let mappedProducts = products.map { $0.fragments.productListItemFragment.convertToProduct() }
        let pagination = ProductListing.Pagination(
            totalCount: totalCount ?? mappedProducts.count,
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
