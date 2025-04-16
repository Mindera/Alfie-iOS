import ApolloTestSupport
import BFFGraphApi
import BFFGraphMocks
import Common
import XCTest

final class BrandConverterTests: XCTestCase {
    func test_brand_valid() {
        let mockQuery = Mock<Query>(
            brands: [
                Mock<Brand>(id: "brand1",
                            name: "Brand 1",
                            slug: "brand-1"),
                Mock<Brand>(id: "brand2",
                            name: "Brand 2",
                            slug: "brand-2")
            ]
        )

        let response = BFFGraphApi.BrandsQuery.Data.from(mockQuery)
        let brands = response.brands.convertToBrands()

        XCTAssertEqual(brands.count, 2)
        XCTAssertEqual(brands[safe: 0]?.id, "brand1")
        XCTAssertEqual(brands[safe: 0]?.name, "Brand 1")
        XCTAssertEqual(brands[safe: 0]?.slug, "brand-1")
        XCTAssertEqual(brands[safe: 1]?.id, "brand2")
        XCTAssertEqual(brands[safe: 1]?.name, "Brand 2")
        XCTAssertEqual(brands[safe: 1]?.slug, "brand-2")
    }
}
