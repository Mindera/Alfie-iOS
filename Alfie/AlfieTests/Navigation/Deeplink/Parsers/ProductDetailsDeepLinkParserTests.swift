import Models
import XCTest
@testable import Alfie

final class ProductDetailsDeepLinkParserTests: XCTestCase {
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
            "\(Self.httpUrl)/product/polo-26146503-suffix-not-expected",
            "\(Self.httpUrl)/product/polo-short-product-id-12345",
            "\(Self.httpUrl)/product/polo-long-product-id-1234567",
        ]

        try assertNoParse(testLinks)
    }


    // MARK: - Product Links

    func test_parses_product_links_with_id_only_as_pdp() throws {
        let testLinks = [
            "\(Self.httpUrl)/product/26146503",
            "\(Self.httpUrl)/product/24449925?something=test",
            "\(Self.httpUrl)/product/25562382?#ins_sr=eyJwcm9kdWN0SWQiOiIyNTU2MjM4MiJ9",
        ]
        try assertParse(testLinks[0],
                        id: "26146503",
                        description: "",
                        route: nil)
        try assertParse(testLinks[1],
                        id: "24449925",
                        description: "",
                        route: nil)
        try assertParse(testLinks[2],
                        id: "25562382",
                        description: "",
                        route: nil)
    }

    func test_ignores_casing_when_parsing_product_links() throws {
        let testLinks = [
            "\(Self.httpUrl)/product/26146503",
            "\(Self.httpUrl)/PRODUCT/24449925",
            "\(Self.httpUrl)/pRoDuCt/25562382",
        ]
        try assertParse(testLinks[0],
                        id: "26146503",
                        description: "",
                        route: nil)
        try assertParse(testLinks[1],
                        id: "24449925",
                        description: "",
                        route: nil)
        try assertParse(testLinks[2],
                        id: "25562382",
                        description: "",
                        route: nil)
    }

    func test_parses_product_links_with_id_and_route_only_as_pdp() throws {
        let testLinks = [
            "\(Self.httpUrl)/product/26146503?nav=885035",
            "\(Self.httpUrl)/product/24449925?something=test&nav=885035",
            "\(Self.httpUrl)/product/25562382?nav=927986#ins_sr=eyJwcm9kdWN0SWQiOiIyNTU2MjM4MiJ9",
        ]
        try assertParse(testLinks[0],
                        id: "26146503",
                        description: "",
                        route: "885035")
        try assertParse(testLinks[1],
                        id: "24449925",
                        description: "",
                        route: "885035")
        try assertParse(testLinks[2],
                        id: "25562382",
                        description: "",
                        route: "927986")
    }

    func test_parses_product_links_with_description_and_route_as_pdp() throws {
        let testLinks = [
            "\(Self.httpUrl)/product/polo-ralph-lauren-ao-short-sleeve-t-shirt-26146503?nav=885035",
            "\(Self.httpUrl)/product/lanc%C3%B4me-absolue-the-serum-30ml-24449925?nav=927986",
            "\(Self.httpUrl)/product/lanc%C3%B4me-advanced-g%C3%A9nifique-youth-activating-concentrate-serum-115ml-22859726?nav=927986",
            "\(Self.httpUrl)/product/bally-bomber%7Cblouson-25642827?nav=881496",
        ]

        try assertParse(testLinks[0],
                        id: "26146503",
                        description: "polo-ralph-lauren-ao-short-sleeve-t-shirt-",
                        route: "885035")
        try assertParse(testLinks[1],
                        id: "24449925",
                        description: "lanc%C3%B4me-absolue-the-serum-30ml-",
                        route: "927986")
        try assertParse(testLinks[2],
                        id: "22859726",
                        description: "lanc%C3%B4me-advanced-g%C3%A9nifique-youth-activating-concentrate-serum-115ml-",
                        route: "927986")
        try assertParse(testLinks[3],
                        id: "25642827",
                        description: "bally-bomber%7Cblouson-",
                        route: "881496")
    }

    // MARK: - Helpers

    private func assertParse(_ link: String,
                             id expectedId: String,
                             description expectedDescription: String,
                             route expectedRoute: String?) throws {
        let testUrl = try XCTUnwrap(URL(string: link))
        let queryParameters = testUrl.queryParameters
        let result = sut.parseUrl(testUrl)
        guard case .productDetail(let id, let description, let route, let query) = result?.type else {
            XCTFail()
            return
        }

        XCTAssertEqual(id, expectedId)
        XCTAssertEqual(description, expectedDescription)
        XCTAssertEqual(route, expectedRoute)
        XCTAssertEqual(query, queryParameters)
    }

    private func assertNoParse(_ links: [String]) throws {
        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))
            let result = sut.parseUrl(testUrl)
            XCTAssertNil(result)
        }
    }
}
