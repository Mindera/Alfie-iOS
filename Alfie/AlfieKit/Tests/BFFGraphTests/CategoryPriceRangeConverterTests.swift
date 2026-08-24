import ApolloTestSupport
@testable import BFFGraph
import Core
import Model
import XCTest

/// Covers the GraphQL→domain bridge itself. `PriceFilterBoundsTests` starts *after* this method,
/// so a swapped min/max or a broken `MoneyFragment` mapping would leave those tests green while
/// production hid the Price row or filtered against the wrong bounds.
final class CategoryPriceRangeConverterTests: XCTestCase {
    // `Money` names both the domain model and the generated Apollo mock.
    private typealias MoneyMock = BFFGraph.Money
    private typealias CategoryPriceRangeMock = BFFGraph.CategoryPriceRange

    func test_response_converts_to_a_price_range() {
        let range = makeResponse(minimum: 20, maximum: 1_300, currencyCode: "GBP").convertToPriceRange()

        XCTAssertEqual(range.low.currencyCode, "GBP")
        XCTAssertEqual(range.high?.currencyCode, "GBP")
    }

    func test_min_and_max_are_not_transposed() {
        let range = makeResponse(minimum: 20, maximum: 1_300, currencyCode: "GBP").convertToPriceRange()

        // The BFF contract is minVariantPrice / maxVariantPrice; swapping them would still produce
        // a PriceRange, and PriceFilterBounds would then reject it as collapsed or invert the UI.
        XCTAssertLessThan(range.low.amount, range.high?.amount ?? .min)
    }

    func test_the_wire_value_is_major_units_and_becomes_minor_on_the_domain_model() {
        // `Money.amount` is minor units; the BFF sends major. £20 must land as 2000, not 20.
        let range = makeResponse(minimum: 20, maximum: 1_300, currencyCode: "GBP").convertToPriceRange()

        XCTAssertEqual(range.low.amount, 2_000)
        XCTAssertEqual(range.high?.amount, 130_000)
    }

    func test_a_zero_exponent_currency_is_not_scaled() {
        let range = makeResponse(minimum: 800, maximum: 48_000, currencyCode: "JPY").convertToPriceRange()

        XCTAssertEqual(range.low.amount, 800)
        XCTAssertEqual(range.high?.amount, 48_000)
    }

    /// End-to-end through the one conversion point the money constraint depends on.
    func test_the_converted_range_yields_the_expected_filter_bounds() {
        let range = makeResponse(minimum: 20, maximum: 1_300, currencyCode: "GBP").convertToPriceRange()
        let bounds = PriceFilterBounds(priceRange: range)

        XCTAssertEqual(bounds?.minimum, 20)
        XCTAssertEqual(bounds?.maximum, 1_300)
    }

    // MARK: - Helpers

    private func makeResponse(
        minimum: Double,
        maximum: Double,
        currencyCode: String
    ) -> BFFGraphAPI.CategoryPriceRangeQuery.Data.CategoryPriceRange {
        BFFGraphAPI.CategoryPriceRangeQuery.Data.CategoryPriceRange.from(
            Mock<CategoryPriceRangeMock>(
                maxVariantPrice: Mock<MoneyMock>(amount: maximum, currencyCode: currencyCode),
                minVariantPrice: Mock<MoneyMock>(amount: minimum, currencyCode: currencyCode)
            )
        )
    }
}
