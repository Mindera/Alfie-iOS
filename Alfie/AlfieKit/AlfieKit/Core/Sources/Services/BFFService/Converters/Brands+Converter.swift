import BFFGraphApi
import Models

extension Collection where Element == BrandsQuery.Data.Brand {
    public func convertToBrands() -> [Brand] {
        map { $0.fragments.brandFragment.convertToBrand() }
    }
}
