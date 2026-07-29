import Model
import XCTest
@testable import DeepLink

final class InternalDeepLinkParserTests: XCTestCase {
    private var sut: InternalDeepLinkParser!
    private var linkConfig: LinkConfiguration!

    private static let appScheme = "alfie"
    private static let host = ThemedURL.internalHost
    private static let appUrl = "\(appScheme)://\(host)"

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
        let testUrl = try XCTUnwrap(URL(string: "/query?param=value"))
        let result = sut.parseUrl(testUrl)
        XCTAssertNil(result)
    }

    func test_does_not_parse_links_with_unknown_hosts() throws {
        let testUrl = try XCTUnwrap(URL(string: "http://unknown.host"))
        let result = sut.parseUrl(testUrl)
        XCTAssertNil(result)
    }

    func test_does_not_parse_links_with_unknown_scheme() throws {
        let testUrl = try XCTUnwrap(URL(string: "http://\(ThemedURL.internalHost)"))
        let result = sut.parseUrl(testUrl)
        XCTAssertNil(result)
    }

    // MARK: - Shop links

    func test_parses_shop_links() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/shop",
            "\(Self.appUrl)/shop/",
        ]

        try assertParse(testLinks, to: .shop(route: ThemedURL.shop.path))
    }

    // MARK: - Other links

    func test_does_not_parse_other_links() throws {
        let testLinks: [String] = [
            Self.appUrl,
            "\(Self.appUrl)/services/store-services",
            "\(Self.appUrl)/something",
            "\(Self.appUrl)/something/",
            "\(Self.appUrl)/something/other",
            "\(Self.appUrl)/something/other/",
            "\(Self.appUrl)/something/other/query?test=value",
        ]
        try assertNoParse(testLinks)
    }

    // MARK: - Helpers

    private func assertParse(_ links: [String], to expectedDeepLinkType: DeepLink.LinkType) throws {
        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))
            let result = sut.parseUrl(testUrl)
            XCTAssertEqual(result?.type, expectedDeepLinkType)
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
