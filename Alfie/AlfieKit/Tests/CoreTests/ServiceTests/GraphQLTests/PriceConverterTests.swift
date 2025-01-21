import XCTest
import ApolloTestSupport
import BFFGraphApi
import BFFGraphMocks

final class PriceConverterTests: XCTestCase {
    func test_price_valid() {
        let mockPrice: Mock<Price> = .mock(amount: .mock(currencyCode: "AUD",
                                                         amount: 10,
                                                         amountFormatted: "$10.00"),
                                           was: .mock(currencyCode: "AUD",
                                                      amount: 20,
                                                      amountFormatted: "$20.00"))

        let response = PriceFragment.from(mockPrice)
        let price = response.convertToPrice()

        XCTAssertEqual(price.amount.currencyCode, "AUD")
        XCTAssertEqual(price.amount.amount, 10)
        XCTAssertEqual(price.amount.amountFormatted, "$10.00")
        XCTAssertEqual(price.was?.currencyCode, "AUD")
        XCTAssertEqual(price.was?.amount, 20)
        XCTAssertEqual(price.was?.amountFormatted, "$20.00")
    }

    func test_price_range_valid() {
        let mockPriceRange: Mock<PriceRange> = .mock(low: .mock(currencyCode: "AUD",
                                                            amount: 1,
                                                            amountFormatted: "$1.00"),
                                                 high: .mock(currencyCode: "AUD",
                                                             amount: 100,
                                                             amountFormatted: "$100.00"))

        let response = PriceRangeFragment.from(mockPriceRange)
        let priceRange = response.convertToPriceRange()

        XCTAssertEqual(priceRange.low.currencyCode, "AUD")
        XCTAssertEqual(priceRange.low.amount, 1)
        XCTAssertEqual(priceRange.low.amountFormatted, "$1.00")
        XCTAssertEqual(priceRange.high?.currencyCode, "AUD")
        XCTAssertEqual(priceRange.high?.amount, 100)
        XCTAssertEqual(priceRange.high?.amountFormatted, "$100.00")
    }

    func test_money_valid() {
        let mockMoney: Mock<Money> = .mock(currencyCode: "AUD",
                                           amount: 1,
                                           amountFormatted: "$1.00")

        let response = MoneyFragment.from(mockMoney)
        let money = response.convertToMoney()

        XCTAssertEqual(money.currencyCode, "AUD")
        XCTAssertEqual(money.amount, 1)
        XCTAssertEqual(money.amountFormatted, "$1.00")
    }
}
