import XCTest
@testable import Model

final class CurrencyFormatterTests: XCTestCase {
    private let enGB = Locale(identifier: "en_GB")

    // MARK: - minorUnitDigits (ISO-4217 exponent)

    func test_minorUnitDigits_perCurrency() {
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "GBP"), 2)
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "USD"), 2)
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "AUD"), 2)
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "JPY"), 0)
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "KWD"), 3)
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "BHD"), 3)
    }

    // MARK: - minorUnits (major → integer minor units, per-currency scale)

    func test_minorUnits_scalesByCurrencyExponent() {
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "10.23")!, currencyCode: "GBP"), 1023)
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "25.00")!, currencyCode: "AUD"), 2500)
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(5000), currencyCode: "JPY"), 5000)
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "19.999")!, currencyCode: "KWD"), 19_999)
    }

    func test_minorUnits_rounds() {
        // 10.235 GBP → 1023.5 minor → rounds to 1024 (plain/half-up).
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "10.235")!, currencyCode: "GBP"), 1024)
    }

    func test_minorUnits_doesNotTruncateBeyondInt32() {
        // £30,000,000 → 3,000,000,000 minor units (> Int32.max) must not overflow/truncate.
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "30000000.00")!, currencyCode: "GBP"), 3_000_000_000)
    }

    // MARK: - string (locale/currency-symbol aware)

    func test_string_GBP_rendersPoundSymbolAndTwoDecimals() {
        let result = CurrencyFormatter.string(amount: Decimal(string: "10.23")!, currencyCode: "GBP", locale: enGB)
        XCTAssertEqual(result, "£10.23")
    }

    func test_string_JPY_hasNoFractionDigitsAndGroups() {
        let result = CurrencyFormatter.string(amount: Decimal(5000), currencyCode: "JPY", locale: enGB)
        XCTAssertFalse(result.contains("."), "JPY (0dp) must not render a decimal separator: \(result)")
        XCTAssertTrue(result.contains("5,000"), "Expected grouped value in \(result)")
    }

    func test_string_KWD_hasThreeFractionDigits() {
        let result = CurrencyFormatter.string(amount: Decimal(string: "19.999")!, currencyCode: "KWD", locale: enGB)
        XCTAssertTrue(result.contains("19.999"), "KWD (3dp) must keep three decimals: \(result)")
    }

    func test_string_USD_showsDollarAndTwoDecimals() {
        let result = CurrencyFormatter.string(amount: Decimal(string: "10.23")!, currencyCode: "USD", locale: enGB)
        XCTAssertTrue(result.contains("$"), "Expected a dollar symbol in \(result)")
        XCTAssertTrue(result.contains("10.23"), "Expected two-decimal value in \(result)")
    }
}
