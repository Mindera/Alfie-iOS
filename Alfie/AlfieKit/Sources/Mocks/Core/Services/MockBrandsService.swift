import Foundation
import Models

public final class MockBrandsService: BrandsServiceProtocol {
    public init() { }

    public var onGetBrandsCalled: (() throws -> [Brand])?
    public func getBrands() async throws -> [Brand] {
        guard let brands = try onGetBrandsCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return brands
    }
}
