import Foundation
import Model

public final class BrandsService: BrandsServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func getBrands() async throws -> [Brand] {
        try await bffClient.getBrands()
    }
}
