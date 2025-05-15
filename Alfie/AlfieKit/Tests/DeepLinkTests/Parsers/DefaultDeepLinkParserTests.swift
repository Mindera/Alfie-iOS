import Model
import XCTest
@testable import DeepLink

final class DefaultDeepLinkParserTests: XCTestCase {
    private var sut: DefaultDeepLinkParser!
    private var linkConfig: LinkConfiguration!

    private static let appScheme = "alfie"
    private static let httpScheme = "http"
    private static let host = ThemedURL.preferredHost
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
        let testUrl = try XCTUnwrap(URL(string: "/query?param=value"))
        let result = sut.parseUrl(testUrl)
        XCTAssertEqual(result?.type, .unknown)
    }

    func test_does_not_parse_links_with_unknown_hosts() throws {
        let testUrl = try XCTUnwrap(URL(string: "http://unknown.host"))
        let result = sut.parseUrl(testUrl)
        XCTAssertEqual(result?.type, .unknown)
    }

    // MARK: - Home links

    func test_parses_home_links() throws {
        let testLinks: [String] = [
            Self.appUrl,
            Self.httpUrl,
            "\(Self.appUrl)/",
            "\(Self.httpUrl)/",
            "\(Self.appUrl)/home",
            "\(Self.httpUrl)/home",
            "\(Self.appUrl)/home/",
            "\(Self.httpUrl)/home/",
        ]

        try assertParse(testLinks, to: .home)
    }

    func test_parses_invalid_home_links_as_web() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/something/home",
            "\(Self.httpUrl)/something/home",
            "\(Self.appUrl)/something/home/",
            "\(Self.httpUrl)/something/home/",
        ]

        try assertFallbackToNormalisedWebViewUrl(testLinks)
    }

    // MARK: - Shop links

    func test_parses_shop_links() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/shop",
            "\(Self.httpUrl)/shop",
            "\(Self.appUrl)/shop/",
            "\(Self.httpUrl)/shop/",
        ]

        try assertParse(testLinks, to: .shop(route: nil))
    }

    func test_parses_special_brands_shop_links() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/brand",
            "\(Self.appUrl)/brand/",
            "\(Self.appUrl)/bRaNd",
            "\(Self.appUrl)/BRAND/",
        ]

        try assertParse(testLinks, to: .shop(route: ThemedURL.brands.path))
    }

    func test_parses_special_services_shop_links() throws {
        let testLinks: [String] = [
            "\(Self.httpUrl)/services/store-services",
            "\(Self.httpUrl)/services/store-services/",
            "\(Self.httpUrl)/SERVICES/store-services",
            "\(Self.httpUrl)/services/sToRe-sErViCeS/",
        ]

        try assertParse(testLinks, to: .shop(route: ThemedURL.services.path))
    }

    func test_parses_invalid_shop_links_as_web() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/something/shop",
            "\(Self.httpUrl)/something/shop",
            "\(Self.appUrl)/something/shop/",
            "\(Self.httpUrl)/something/shop/",
            "\(Self.httpUrl)/brands",
            "\(Self.httpUrl)/service/store-services",
            "\(Self.httpUrl)/services/storeservices",
        ]

        try assertFallbackToNormalisedWebViewUrl(testLinks)
    }

    // MARK: - Bag links

    func test_parses_bag_links() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/bag",
            "\(Self.httpUrl)/bag",
            "\(Self.appUrl)/bag/",
            "\(Self.httpUrl)/bag/",
        ]

        try assertParse(testLinks, to: .bag)
    }

    func test_parses_invalid_bag_links_as_web() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/something/bag",
            "\(Self.httpUrl)/something/bag",
            "\(Self.appUrl)/something/bag/",
            "\(Self.httpUrl)/something/bag/",
        ]

        try assertFallbackToNormalisedWebViewUrl(testLinks)
    }

    // MARK: - Wishlist links

    func test_parses_wishlist_links() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/wishlist",
            "\(Self.httpUrl)/wishlist",
            "\(Self.appUrl)/wishlist/",
            "\(Self.httpUrl)/wishlist/",
        ]

        try assertParse(testLinks, to: .wishlist)
    }

    func test_parses_invalid_wishlist_links_as_web() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/something/wishlist",
            "\(Self.httpUrl)/something/wishlist",
            "\(Self.appUrl)/something/wishlist/",
            "\(Self.httpUrl)/something/wishlist/",
        ]

        try assertFallbackToNormalisedWebViewUrl(testLinks)
    }

    // MARK: - Account links

    func test_parses_account_links() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/account",
            "\(Self.httpUrl)/account",
            "\(Self.appUrl)/account/",
            "\(Self.httpUrl)/account/",
        ]
        try assertParse(testLinks, to: .account)
    }

    func test_parses_invalid_account_links_as_web() throws {
        let testLinks: [String] = [
            "\(Self.appUrl)/something/account",
            "\(Self.httpUrl)/something/account",
            "\(Self.appUrl)/something/account/",
            "\(Self.httpUrl)/something/account/",
        ]
        try assertFallbackToNormalisedWebViewUrl(testLinks)
    }

    // MARK: - Other links

    func test_parses_other_links() throws {
        let testLinks = [
            "http://\(Self.host)/en-gb/some/other/link",
            "http://\(Self.host)/link?key=value",
            "http://\(Self.host)/english-usa",
            "http://\(Self.host)/en-12",
            "http://\(Self.host)/12-us",
            "http://\(Self.host)/12-34",
        ]

        try assertFallbackToNormalisedWebViewUrl(testLinks)
    }

    // MARK: - Helpers

    private func assertParse(_ links: [String], to expectedDeepLinkType: DeepLink.LinkType) throws {
        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))
            let result = sut.parseUrl(testUrl)
            XCTAssertEqual(result?.type, expectedDeepLinkType)
        }
    }

    private func assertFallbackToNormalisedWebViewUrl(_ links: [String]) throws {
        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))
            let result = sut.parseUrl(testUrl)
            guard case .webView(let url) = result?.type else {
                XCTFail("Unexpected deeplink type for \(testUrl)")
                return
            }
            XCTAssertEqual(url.scheme, linkConfig.defaultHttpScheme)
        }
    }
}
