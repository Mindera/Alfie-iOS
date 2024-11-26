import Models
import XCTest
@testable import Alfie

final class ProductListingDeepLinkParserTests: XCTestCase {
    private var sut: ProductListingDeepLinkParser!
    private var linkConfig: LinkConfiguration!

    private static let appScheme = "alfie"
    private static let httpScheme = "http"
    private static let host = "localhost:4000"
    private static let appUrl = "\(appScheme)://\(host)"
    private static let httpUrl = "\(httpScheme)://\(host)"

    override func setUpWithError() throws {
        try super.setUpWithError()
        linkConfig = .init()
        sut = .init(configuration: linkConfig)
    }

    override func tearDownWithError() throws {
        sut = nil
        linkConfig = nil
        try super.tearDownWithError()
    }

    // MARK: - Invalid links

    func test_does_not_parse_invalid_links() throws {
        let testLinks = [
            "/query?param=value"
        ]

        try assertNoParse(testLinks)
    }

    func test_does_not_parse_links_with_unknown_hosts() throws {
        let testLinks = [
            "http://unknown.host"
        ]

        try assertNoParse(testLinks)
    }

    // MARK: - Category Links

    func test_parses_category_links_as_plp() throws {
        let testLinks = [
            "http://\(Self.host)/designer",
            "http://\(Self.host)/sale",
            "http://\(Self.host)/women",
            "http://\(Self.host)/men",
            "http://\(Self.host)/shoes",
            "http://\(Self.host)/bags-and-accessories",
            "http://\(Self.host)/beauty",
            "http://\(Self.host)/kids",
            "http://\(Self.host)/home-and-food",
            "http://\(Self.host)/electrical",
        ]

        try assertParse(testLinks)
    }

    // MARK: - Sub-category Links

    func test_parses_subcategory_links_as_plp() throws {
        let testLinks = [
            "http://\(Self.host)/women/clothing",
            "http://\(Self.host)/women/clothing/dresses",
            "http://\(Self.host)/women/clothing/dresses/maxi-dresses",
        ]

        try assertParse(testLinks)
    }

    // MARK: - Unknown Category Links

    func test_does_not_parse_unknown_category_links_as_plp() throws {
        let testLinks = [
            "http://\(Self.host)/something",
            "http://\(Self.host)/123",
            "http://\(Self.host)/something/else",
            "http://\(Self.host)/something/else/unknown",
            "http://\(Self.host)/prefix/women",
        ]

        try assertNoParse(testLinks)
    }

    // MARK: - Category Links with query parameters

    func test_parses_category_links_with_query_as_plp() throws {
        let testLinks = [
            "http://\(Self.host)/designer?query1=value&query2=value2",
            "http://\(Self.host)/designer?query1=value",
            "http://\(Self.host)/designer?query1=value&query2=222",
        ]

        try assertParse(testLinks)
    }

    // MARK: - Sub-category Links with query parameters

    func test_parses_subcategory_links_with_query_as_plp() throws {
        let testLinks = [
            "http://\(Self.host)/women/clothing/dresses?query1=value&query2=value2",
            "http://\(Self.host)/women/clothing/dresses?query1=value",
            "http://\(Self.host)/women/clothing/dresses?query1=value&query2=222",
        ]

        try assertParse(testLinks)
    }

    // MARK: - Special Brand cases

    func test_parses_brand_links_as_plp() throws {
        let testLinks = [
            "http://\(Self.host)/brand/prada",
            "http://\(Self.host)/brand/prada/",
            "http://\(Self.host)/brand/prada?query1=value",
        ]

        try assertParse(testLinks)
    }

    func test_does_not_parse_brand_links_without_brand_name_component() throws {
        let testLinks = [
            "http://\(Self.host)/brand",
            "http://\(Self.host)/brands",
        ]

        try assertNoParse(testLinks)
    }

    func test_does_not_parse_brand_links_with_multiple_brand_name_component() throws {
        let testLinks = [
            "http://\(Self.host)/brand/gucci/dresses",
            "http://\(Self.host)/brand/gucci/dresses?query1=value",
        ]

        try assertNoParse(testLinks)
    }

    // MARK: - Helpers

    private func assertParse(_ links: [String]) throws {
        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))
            let queryParameters = testUrl.queryParameters
            let result = sut.parseUrl(testUrl)
            guard case .productList(let category, let query, let parameters) = result?.type else {
                XCTFail()
                return
            }
            XCTAssertEqual(category, testUrl.cleanPath)
            XCTAssertNil(query)
            XCTAssertEqual(parameters, queryParameters)
        }
    }

    private func assertNoParse(_ links: [String]) throws {
        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))
            let result = sut.parseUrl(testUrl)
            XCTAssertNil(result)
        }
    }
}
