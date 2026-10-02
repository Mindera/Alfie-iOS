import Model
import XCTest
@testable import DeepLink

final class ProductDetailsDeepLinkParserTests: XCTestCase {
    private typealias ParseCase = (link: String, handle: String, route: String?, query: [String: String]?)

    private var sut: ProductDetailsDeepLinkParser!
    private var linkConfig: LinkConfiguration!

    private static let httpScheme = "http"
    private static let host = ThemedURL.preferredHost
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
            "/query?param=value",
        ]

        try assertNoParse(testLinks)
    }

    func test_does_not_parse_links_with_unknown_hosts() throws {
        let testLinks = [
            "http://unknown.host"
        ]

        try assertNoParse(testLinks)
    }

    func test_does_not_parse_links_with_invalid_path() throws {
        let testLinks = [
            "\(Self.httpUrl)/products",
            "\(Self.httpUrl)/products/polo-26146503?nav=885035/",
            "\(Self.httpUrl)/product/",
            // Only separators after the prefix, so there is no Handle to resolve.
            "\(Self.httpUrl)/product//",
        ]

        try assertNoParse(testLinks)
    }


    // MARK: - Product Links

    func test_parses_product_links_with_numeric_handle_as_pdp() throws {
        let cases: [ParseCase] = [
            ("\(Self.httpUrl)/product/26146503", "26146503", nil, nil),
            ("\(Self.httpUrl)/product/24449925?something=test", "24449925", nil, ["something": "test"]),
            ("\(Self.httpUrl)/product/25562382?#ins_sr=eyJwcm9kdWN0SWQiOiIyNTU2MjM4MiJ9", "25562382", nil, [:]),
        ]

        try assertParse(cases)
    }

    func test_ignores_casing_when_parsing_product_links() throws {
        let cases: [ParseCase] = [
            ("\(Self.httpUrl)/product/26146503", "26146503", nil, nil),
            ("\(Self.httpUrl)/PRODUCT/24449925", "24449925", nil, nil),
            ("\(Self.httpUrl)/pRoDuCt/25562382", "25562382", nil, nil),
        ]

        try assertParse(cases)
    }

    func test_parses_product_links_with_numeric_handle_and_route_as_pdp() throws {
        let cases: [ParseCase] = [
            ("\(Self.httpUrl)/product/26146503?nav=885035", "26146503", "885035", ["nav": "885035"]),
            (
                "\(Self.httpUrl)/product/24449925?something=test&nav=885035",
                "24449925",
                "885035",
                ["something": "test", "nav": "885035"]
            ),
            (
                "\(Self.httpUrl)/product/25562382?nav=927986#ins_sr=eyJwcm9kdWN0SWQiOiIyNTU2MjM4MiJ9",
                "25562382",
                "927986",
                ["nav": "927986"]
            ),
        ]

        try assertParse(cases)
    }

    func test_parses_product_links_with_handle_and_route_as_pdp() throws {
        let cases: [ParseCase] = [
            (
                "\(Self.httpUrl)/product/polo-ralph-lauren-ao-short-sleeve-t-shirt-26146503?nav=885035",
                "polo-ralph-lauren-ao-short-sleeve-t-shirt-26146503",
                "885035",
                ["nav": "885035"]
            ),
            (
                "\(Self.httpUrl)/product/lanc%C3%B4me-absolue-the-serum-30ml-24449925?nav=927986",
                "lanc%C3%B4me-absolue-the-serum-30ml-24449925",
                "927986",
                ["nav": "927986"]
            ),
            (
                "\(Self.httpUrl)/product/lanc%C3%B4me-advanced-g%C3%A9nifique-youth-activating-concentrate-serum-115ml-22859726?nav=927986",
                "lanc%C3%B4me-advanced-g%C3%A9nifique-youth-activating-concentrate-serum-115ml-22859726",
                "927986",
                ["nav": "927986"]
            ),
            (
                "\(Self.httpUrl)/product/bally-bomber%7Cblouson-25642827?nav=881496",
                "bally-bomber%7Cblouson-25642827",
                "881496",
                ["nav": "881496"]
            ),
        ]

        try assertParse(cases)
    }

    func test_parses_bare_handle_links_as_pdp() throws {
        // Real Handles are bare, with no trailing numeric id: the whole path after the `/product/`
        // prefix is the Handle, used as-is.
        let cases: [ParseCase] = [
            ("\(Self.httpUrl)/product/t-shirt", "t-shirt", nil, nil),
            (
                "\(Self.httpUrl)/product/la-mer-creme-de-la-mer-moisturizing-cream",
                "la-mer-creme-de-la-mer-moisturizing-cream",
                nil,
                nil
            ),
            ("\(Self.httpUrl)/product/polo-short-product-id-12345", "polo-short-product-id-12345", nil, nil),
        ]

        try assertParse(cases)
    }

    func test_parses_product_links_with_multi_segment_handle_as_pdp() throws {
        // A Handle is platform-shaped: on BigCommerce it is a site route path and routinely contains
        // slashes, so everything after the `/product/` prefix is the Handle.
        let cases: [ParseCase] = [
            ("\(Self.httpUrl)/product/women/dresses/red-midi-dress", "women/dresses/red-midi-dress", nil, nil),
            ("\(Self.httpUrl)/product/t-shirt/reviews", "t-shirt/reviews", nil, nil),
            ("\(Self.httpUrl)/PRODUCT/women/dresses/red-midi-dress", "women/dresses/red-midi-dress", nil, nil),
        ]

        try assertParse(cases)
    }

    func test_parses_multi_segment_handle_with_route_and_unknown_query_parameters() throws {
        let cases: [ParseCase] = [
            (
                "\(Self.httpUrl)/product/women/dresses/red-midi-dress?nav=885035",
                "women/dresses/red-midi-dress",
                "885035",
                ["nav": "885035"]
            ),
            (
                "\(Self.httpUrl)/product/beauty/lanc%C3%B4me-absolue-the-serum-30ml?unknown=1&nav=927986",
                "beauty/lanc%C3%B4me-absolue-the-serum-30ml",
                "927986",
                ["unknown": "1", "nav": "927986"]
            ),
            (
                "\(Self.httpUrl)/product/women/dresses/red-midi-dress?unknown=1",
                "women/dresses/red-midi-dress",
                nil,
                ["unknown": "1"]
            ),
        ]

        try assertParse(cases)
    }

    func test_preserves_an_unknown_sku_query_parameter_when_parsing() throws {
        // A scanned Alfie code carries the Variant's SKU alongside the Handle. The parser does not
        // interpret it, but it must neither choke on it nor drop it from the parsed query.
        let testUrl = try XCTUnwrap(URL(string: "\(Self.httpUrl)/product/mens/jeans/slim-indigo?sku=12345"))

        guard case .productDetail(let handle, let route, let query) = sut.parseUrl(testUrl)?.type else {
            XCTFail("Expected \(testUrl) to parse as a product detail link")
            return
        }

        XCTAssertEqual(handle, "mens/jeans/slim-indigo")
        XCTAssertNil(route)
        XCTAssertEqual(query?["sku"], "12345")
    }

    func test_ignores_trailing_slash_when_parsing_handles() throws {
        let cases: [ParseCase] = [
            ("\(Self.httpUrl)/product/t-shirt/", "t-shirt", nil, nil),
            (
                "\(Self.httpUrl)/product/women/dresses/red-midi-dress/?nav=885035",
                "women/dresses/red-midi-dress",
                "885035",
                ["nav": "885035"]
            ),
            // However many separators trail the Handle.
            ("\(Self.httpUrl)/product/t-shirt///", "t-shirt", nil, nil),
        ]

        try assertParse(cases)
    }

    // MARK: - Helpers

    private func assertParse(_ cases: [ParseCase], file: StaticString = #filePath, line: UInt = #line) throws {
        for testCase in cases {
            let testUrl = try XCTUnwrap(URL(string: testCase.link), file: file, line: line)

            let result = sut.parseUrl(testUrl)

            guard case .productDetail(let handle, let route, let query) = result?.type else {
                XCTFail("Expected \(testCase.link) to parse as a product detail link", file: file, line: line)
                continue
            }
            XCTAssertEqual(handle, testCase.handle, "handle for \(testCase.link)", file: file, line: line)
            XCTAssertEqual(route, testCase.route, "route for \(testCase.link)", file: file, line: line)
            XCTAssertEqual(query, testCase.query, "query for \(testCase.link)", file: file, line: line)
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
