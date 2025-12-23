import Foundation

public protocol BrandsServiceProtocol {
    func getBrands() async throws -> [Brand]
}
