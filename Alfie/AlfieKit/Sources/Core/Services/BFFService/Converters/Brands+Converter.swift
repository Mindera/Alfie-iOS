import BFFGraph
import Model

extension Collection where Element == BFFGraphApi.BrandsQuery.Data.Brand {
    public func convertToBrands() -> [Brand] {
        map { $0.fragments.brandFragment.convertToBrand() }
    }
}
