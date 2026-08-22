import XCTest
@testable import Model

final class CurrencyFormatterTests: XCTestCase {
    private let enGB = Locale(identifier: "en_GB")
    private let deDE = Locale(identifier: "de_DE")

    // MARK: - minorUnitDigits (ISO-4217 exponent)

    func test_minor_unit_digits_per_currency() {
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

    func test_minor_unit_digits_is_consistent_across_repeated_calls() {
        // Memoised — repeated calls must still return the correct, stable value.
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "GBP"), 2)
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "GBP"), 2)
    }

    func test_minor_unit_digits_is_concurrency_safe() {
        // Converters run off-main on the cooperative pool; hammering the memoised cache
        // concurrently must not crash or corrupt (guards against dropping the lock).
        let codes = ["GBP", "USD", "JPY", "KWD", "EUR", "AUD"]
        DispatchQueue.concurrentPerform(iterations: 1_000) { i in
            _ = CurrencyFormatter.minorUnitDigits(for: codes[i % codes.count])
        }
        XCTAssertEqual(CurrencyFormatter.minorUnitDigits(for: "JPY"), 0)
    }

    // MARK: - minorUnits (major → integer minor units, per-currency scale)

    func test_minor_units_scales_by_currency_exponent() throws {
        let cases: [(amount: String, code: String, expected: Int)] = [
            ("10.23", "GBP", 1023),    // 2dp
            ("25.00", "AUD", 2500),    // 2dp, whole
            ("5000", "JPY", 5000),     // 0dp — no ×100
            ("19.999", "KWD", 19_999), // 3dp
        ]
        for entry in cases {
            let amount = try XCTUnwrap(Decimal(string: entry.amount), "Unparseable test literal: \(entry.amount)")
            XCTAssertEqual(
                CurrencyFormatter.minorUnits(of: amount, currencyCode: entry.code), entry.expected,
                "\(entry.amount) \(entry.code) should scale to \(entry.expected) minor units"
            )
        }
    }

    func test_minor_units_zero_and_negative() {
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: .zero, currencyCode: "GBP"), 0)
        // Negative (e.g. a markdown/credit) must scale and keep sign.
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "-10.50")!, currencyCode: "GBP"), -1050)
    }

    func test_minor_units_rounds_half_away_from_zero() {
        // x.xx5 at the minor-unit boundary rounds away from zero (.plain), symmetrically.
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "10.235")!, currencyCode: "GBP"), 1024)
        XCTAssertEqual(CurrencyFormatter.minorUnits(of: Decimal(string: "-10.235")!, currencyCode: "GBP"), -1024)
    }

    func test_minor_units_does_not_truncate_beyond_int32() {
        // £30,000,000 → 3,000,000,000 minor units (> Int32.max) must not overflow/truncate.
        XCTAssertEqual(
            CurrencyFormatter.minorUnits(of: Decimal(string: "30000000.00")!, currencyCode: "GBP"),
            3_000_000_000
        )
    }

    // MARK: - symbol (glyph only, for use as a field affix)

    func test_symbol_returns_the_glyph_not_the_code() {
        XCTAssertEqual(CurrencyFormatter.symbol(for: "GBP", locale: enGB), "£")
        XCTAssertEqual(CurrencyFormatter.symbol(for: "EUR", locale: enGB), "€")
    }

    func test_symbol_matches_the_symbol_rendered_prices_use() {
        // The affix sits beside a plain numeric field standing in for a formatted price, so it has
        // to be the same glyph `string(...)` renders — including the disambiguated forms the
        // locale applies to non-home currencies (en_GB renders USD as "US$", not "$").
        for code in ["GBP", "USD", "EUR", "JPY"] {
            let symbol = CurrencyFormatter.symbol(for: code, locale: enGB)
            let formatted = CurrencyFormatter.string(amount: Decimal(12), currencyCode: code, locale: enGB)
            XCTAssertTrue(
                formatted.hasPrefix(symbol),
                "\(code): affix \"\(symbol)\" should match the rendered price \"\(formatted)\""
            )
        }
    }

    func test_symbol_falls_back_to_the_code_when_unrecognised() {
        XCTAssertEqual(CurrencyFormatter.symbol(for: "ZZZ", locale: enGB), "ZZZ")
    }

    func test_symbol_is_consistent_across_repeated_calls() {
        // Memoised per (code, locale) — repeated calls must return the same glyph.
        XCTAssertEqual(CurrencyFormatter.symbol(for: "GBP", locale: enGB), "£")
        XCTAssertEqual(CurrencyFormatter.symbol(for: "GBP", locale: enGB), "£")
    }

    func test_symbol_is_concurrency_safe() {
        let codes = ["GBP", "USD", "JPY", "EUR"]
        DispatchQueue.concurrentPerform(iterations: 1_000) { i in
            _ = CurrencyFormatter.symbol(for: codes[i % codes.count], locale: self.enGB)
        }
        XCTAssertEqual(CurrencyFormatter.symbol(for: "GBP", locale: enGB), "£")
    }

    func test_symbol_is_locale_aware() {
        // The same currency can carry a different glyph per locale, so the cache is keyed by both.
        XCTAssertEqual(CurrencyFormatter.symbol(for: "USD", locale: Locale(identifier: "en_US")), "$")
        XCTAssertEqual(CurrencyFormatter.symbol(for: "USD", locale: enGB), "US$")
    }

    // MARK: - string (locale/currency-symbol aware)

    func test_string_gbp_renders_pound_symbol_and_two_decimals() {
        let result = CurrencyFormatter.string(amount: Decimal(string: "10.23")!, currencyCode: "GBP", locale: enGB)
        XCTAssertEqual(result, "£10.23")
    }

    func test_string_jpy_has_no_fraction_digits_and_groups() {
        let result = CurrencyFormatter.string(amount: Decimal(5000), currencyCode: "JPY", locale: enGB)
        XCTAssertFalse(result.contains("."), "JPY (0dp) must not render a decimal separator: \(result)")
        XCTAssertTrue(result.contains("5,000"), "Expected grouped value in \(result)")
    }

    func test_string_kwd_has_three_fraction_digits() {
        let result = CurrencyFormatter.string(amount: Decimal(string: "19.999")!, currencyCode: "KWD", locale: enGB)
        XCTAssertTrue(result.contains("19.999"), "KWD (3dp) must keep three decimals: \(result)")
    }

    func test_string_usd_shows_dollar_and_two_decimals() {
        let result = CurrencyFormatter.string(amount: Decimal(string: "10.23")!, currencyCode: "USD", locale: enGB)
        XCTAssertTrue(result.contains("$"), "Expected a dollar symbol in \(result)")
        XCTAssertTrue(result.contains("10.23"), "Expected two-decimal value in \(result)")
    }

    func test_string_is_locale_aware_separators_follow_locale() {
        // Same currency, different locale → different grouping/decimal separators.
        let gb = CurrencyFormatter.string(amount: Decimal(1234.5), currencyCode: "GBP", locale: enGB)
        let de = CurrencyFormatter.string(amount: Decimal(1234.5), currencyCode: "GBP", locale: deDE)
        XCTAssertNotEqual(gb, de, "Formatting should reflect the supplied locale")
        XCTAssertTrue(gb.contains("1,234.50"), "en_GB groups with ',' and decimals with '.': \(gb)")
    }
}
