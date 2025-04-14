import Core
@testable import SharedUI
import XCTest

final class LocalizationTests: XCTestCase {
    let localizations = Bundle.main.localizations

    func testLocalizationTables() {
        testTable(tableName: "L10n", keys: L10n.Keys.self)
    }

    func testLocalizableHomeWithArgs() {
        localizations.forEach { localization in
            let headerTitle = L10n.Home.LoggedIn.title("test")
            let headerSubtitle = L10n.Home.LoggedIn.subtitle("2024")
            let resources: [String] = [headerTitle, headerSubtitle]
            XCTAssertTrue(validateLocalizedStrings(resources, for: localization))
        }
    }

    func test_localizable_search_with_args() {
        localizations.forEach { localization in
            let noResults = L10n.Search.Screen.NoResultsView.term("test")
            let resources: [String] = [noResults]
            XCTAssertTrue(validateLocalizedStrings(resources, for: localization))
        }
    }

    func testLocalizableProductListingResultsWithArgs() {
        localizations.forEach { localization in
            let resources = [0, 1, 2].map { L10n.Plp.NumberOfResults.message($0) }
            XCTAssertTrue(validateLocalizedStrings(resources, for: localization))
        }
    }

    // MARK: - Test String Replacer Regex private helper

    func test_StringReplacerRegex_ForObjectSpecifier_Failing() {
        let objectSpecifier = "This is a replacer %@ for object specifier"
        XCTAssertFalse(validateLocalizedStrings([objectSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForIntegerSpecifier_Failing() {
        let integerSpecifier = "This is a replacer %d for integer specifier"
        XCTAssertFalse(validateLocalizedStrings([integerSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForFloatingSpecifier_Failing() {
        let floatingSpecifier = "This is a replacer %f for floating specifier"
        XCTAssertFalse(validateLocalizedStrings([floatingSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForStringSpecifier_Failing() {
        let stringSpecifier = "This is a replacer %s for string specifier"
        XCTAssertFalse(validateLocalizedStrings([stringSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForUIntegerSpecifier_Failing() {
        let uIntegerSpecifier = "This is a replacer %u for unsigned integer specifier"
        XCTAssertFalse(validateLocalizedStrings([uIntegerSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForPositionalObjectSpecifier_Failing() {
        let positionalObjectSpecifier = "This is a replacer %1$@ for positional object specifier %2$@"
        XCTAssertFalse(validateLocalizedStrings([positionalObjectSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForPositionalIntegerSpecifier_Failing() {
        let positionalIntegerSpecifier = "This is a replacer %1$d for positional integer specifier %2$d"
        XCTAssertFalse(validateLocalizedStrings([positionalIntegerSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForPositionalFloatingSpecifier_Failing() {
        let positionalFloatingSpecifier = "This is a replacer %1$f for positional floating specifier %2$f"
        XCTAssertFalse(validateLocalizedStrings([positionalFloatingSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForPositionalStringSpecifier_Failing() {
        let positionalStringSpecifier = "This is a replacer %1$s for positional string specifier %2$s"
        XCTAssertFalse(validateLocalizedStrings([positionalStringSpecifier], for: "en"))
    }

    func test_StringReplacerRegex_ForPositionalUIntegerSpecifier_Failing() {
        let positionalUIntegerSpecifier = "This is a replacer %1$u for positional unsigned integer specifier %2$u"
        XCTAssertFalse(validateLocalizedStrings([positionalUIntegerSpecifier], for: "en"))
    }

    // MARK: - Private Test Helpers

    private func testTable<Keys>(tableName: String, keys: Keys.Type) where Keys: RawRepresentable & CaseIterable, Keys.RawValue == String {
        Keys.allCases.forEach { key in
            localizeResource(key: key.rawValue, table: tableName)
        }
    }

    private func localizeResource(key: String, table: String) {
        localizations.forEach { localization in
            let locale: Locale = .init(identifier: localization)
            assertResource(key: key, table: table, locale: locale)
        }
    }

    private func assertResource(key: String, table: String, locale: Locale) {
        guard
            let path = BundleToken.bundle.path(forResource: locale.identifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            XCTFail("Missing bundle for locale: \(locale.identifier)")
            return
        }

        let resource = bundle.localizedString(forKey: key, value: nil, table: table)
        if resource == key {
            XCTFail("\(table).\(key) not found for \(locale.identifier)")
        }
    }

    private func validateLocalizedStrings(_ strings: [String], for localization: String) -> Bool {
        
        // The regex /%(\d+\$)?[@dfsu]/ matches:
        // %@: Object specifier.
        // %d: Integer specifier.
        // %f: Floating-point specifier.
        // %s: String specifier.
        // %u: Unsigned integer specifier.
        // %1$@, %2$d, etc.: Positional specifiers.
        let unresolvedPlaceholderPattern = /%(\d+\$)?[@dfsu]/

        return strings.allSatisfy { value in
            !value.isEmpty && !value.contains(unresolvedPlaceholderPattern)
        }
    }
}
