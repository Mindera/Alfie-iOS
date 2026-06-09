import XCTest
@testable import Model

final class CurrencyFormatterTests: XCTestCase {
    private let enGB = Locale(identifier: "en_GB")

    // MARK: - minorUnitDigits (ISO-4217 exponent)

    func test_minorUnitDigits_perCurrency() {
        let cases: [(code: String, digits: Int)] = [
            ("GBP", 2), ("USD", 2), ("AUD", 2), ("EUR", 2),
            ("JPY", 0), ("KWD", 3), ("BHD", 3),
        ]
        for entry in cases {
            XCTAssertEqual(
                CurrencyFormatter.minorUnitDigits(for: entry.code), entry.digits,
                "Expected \(entry.digits) minor-unit digits for \(entry.code)"
            )
        }
    }

    // MARK: - minorUnits (major → integer minor units, per-currency scale)

    func test_minorUnits_scalesByCurrencyExponent() {
        let cases: [(amount: String, code: String, expected: Int)] = [
            ("10.23", "GBP", 1023),   // 2dp
            ("25.00", "AUD", 2500),   // 2dp, whole
            ("5000", "JPY", 5000),    // 0dp — no ×100
            ("19.999", "KWD", 19_999), // 3dp
        ]
        for entry in cases {
            let amount = try? XCTUnwrap(Decimal(string: entry.amount))
            XCTAssertEqual(
                CurrencyFormatter.minorUnits(of: amount ?? .zero, currencyCode: entry.code), entry.expected,
                "\(entry.amount) \(entry.code) should scale to \(entry.expected) minor units"
            )
        }
    }

    func test_minorUnits_zeroAndNegative() {
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: .zero, currencyCode: "GBP"), 0)
        // Negative (e.g. a markdown/credit) must scale and keep sign.
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "-10.50")!, currencyCode: "GBP"), -1050)
    }

    func test_minorUnits_roundsHalfAwayFromZero() {
        // x.xx5 at the minor-unit boundary rounds away from zero (.plain), symmetrically.
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "10.235")!, currencyCode: "GBP"), 1024)
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "-10.235")!, currencyCode: "GBP"), -1024)
    }

    func test_minorUnits_doesNotTruncateBeyondInt32() {
        // £30,000,000 → 3,000,000,000 minor units (> Int32.max) must not overflow/truncate.
        XCTAssertEqual(
            CurrencyFormatter.minorUnits(of: Decimal(string: "30000000.00")!, currencyCode: "GBP"),
            3_000_000_000
        )
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

    func test_string_isLocaleAware_separatorsFollowLocale() {
        // Same currency, different locale → different grouping/decimal separators.
        let gb = CurrencyFormatter.string(amount: Decimal(1234.5), currencyCode: "GBP", locale: Locale(identifier: "en_GB"))
        let de = CurrencyFormatter.string(amount: Decimal(1234.5), currencyCode: "GBP", locale: Locale(identifier: "de_DE"))
        XCTAssertNotEqual(gb, de, "Formatting should reflect the supplied locale")
        XCTAssertTrue(gb.contains("1,234.50"), "en_GB groups with ',' and decimals with '.': \(gb)")
    }
}
