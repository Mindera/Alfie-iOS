import XCTest
@testable import Alfie

final class LocalizationTests: XCTestCase {
    let localizations = Bundle.main.localizations

    func testLocalizationTables() {
        testTable(LocalizableGeneral.self)
        testTable(LocalizableHome.self)
        testTable(LocalizableShop.self)
        testTable(LocalizableBag.self)
        testTable(LocalizableAccount.self)
        testTable(LocalizableSearch.self)
        testTable(LocalizableSortBy.self)
        testTable(LocalizableBrands.self)
        testTable(LocalizableWebView.self)
        testTable(LocalizableCategories.self)
    }

    func testLocalizableBagWithArgs() {
        localizations.forEach { localization in
            let locale: Locale = .init(identifier: localization)
            let resources = [0, 1, 2].map { LocalizableBag.bagProductDescription(numberOfProducts: $0, locale: locale) }
            resources.forEach { resource in
                let value = String(localized: resource)
                if value == resource.key || value.isEmpty {
                    XCTFail("LocalizableBag.bagProductDescription with \(resource.defaultValue) not found for \(locale.identifier)")
                }
            }
        }
    }

    func testLocalizableHomeWithArgs() {
        localizations.forEach { localization in
            let locale: Locale = .init(identifier: localization)
            let headerTitle = LocalizableHome.loggedInHeaderTitle(username: "test", locale: locale)
            let headerSubtitle = LocalizableHome.loggedInHeaderSubtitle(registrationYear: "2024", locale: locale)
            let resources: [LocalizedStringResource] = [headerTitle, headerSubtitle]
            resources.forEach { resource in
                let value = String(localized: resource)
                if value == resource.key || value.isEmpty {
                    XCTFail("LocalizableHome.\(resource.key) with \(resource.defaultValue) not found for \(locale.identifier)")
                }
            }
        }
    }

    func test_localizable_search_with_args() {
        localizations.forEach { localization in
            let locale: Locale = .init(identifier: localization)
            let noResults = LocalizableSearch.searchNoResults(for: "test", locale: locale)
            let resources: [LocalizedStringResource] = [noResults]
            resources.forEach { resource in
                let value = String(localized: resource)
                if value == resource.key || value.isEmpty {
                    XCTFail("LocalizableSearch.\(resource.key) with \(resource.defaultValue) not found for \(locale.identifier)")
                }
            }
        }
    }

    func testLocalizableProductListingResultsWithArgs() {
        localizations.forEach { localization in
            let locale: Locale = .init(identifier: localization)
            let resources = [1, 2].map { LocalizableProductListing.results($0, locale: locale) }
            resources.forEach { resource in
                let value = String(localized: resource)
                if value == resource.key || value.isEmpty {
                    XCTFail("LocalizableProductListing.results with \(resource.defaultValue) not found for \(locale.identifier)")
                }
            }
        }
    }

    // MARK: - Private Test Helpers

    private func testTable<T: LocalizableProtocol>(_ table: T.Type) {
        table.Keys.allCases.forEach { key in
            localizeResource(key: key.rawValue, table: table.tableName)
        }
    }

    private func localizeResource(key: String, table: String) {
        localizations.forEach { localization in
            let locale: Locale = .init(identifier: localization)
            assertResource(key: key, table: table, locale: locale)
        }
    }

    private func assertResource(key: String, table: String, locale: Locale) {
        let resource = LocalizedStringResource(String.LocalizationValue(stringLiteral: key), table: table, locale: locale)
        if String(localized: resource) == key {
            XCTFail("\(table).\(key) not found for \(locale.identifier)")
        }
    }
}
