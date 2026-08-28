import BFFGraph
import Foundation
import Model

extension BFFGraphAPI.CategoryPriceRangeQuery.Data.CategoryPriceRange {
    /// The BFF contract is `minVariantPrice` / `maxVariantPrice`; both are non-null, so the
    /// domain `PriceRange`'s optional `high` is always populated here.
    public func convertToPriceRange() -> PriceRange {
        PriceRange(
            low: minVariantPrice.fragments.moneyFragment.toDomainMoney(),
            high: maxVariantPrice.fragments.moneyFragment.toDomainMoney()
        )
    }
}
