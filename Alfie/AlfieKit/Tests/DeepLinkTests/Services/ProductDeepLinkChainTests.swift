import Core
import Mocks
import Model
import XCTest
@testable import DeepLink

/// Exercises the ordered parser chain the app actually installs, rather than a parser in isolation:
/// a product link only reaches the Product Details page if no earlier parser claims it first, and a
/// non-product link has to survive all the way down to the web-view fallback.
final class ProductDeepLinkChainTests: XCTestCase {
    private var sut: DeepLinkService!

    private static let httpUrl = "http://\(ThemedURL.preferredHost)"

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DeepLinkService(configuration: LinkConfiguration(), log: MockLogger())
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    /// Both shapes, because the parser ahead of `ProductDetailsDeepLinkParser` in the chain claims links
    /// by first path component: a multi-segment Handle is the shape at risk of being claimed early.
    func test_product_links_open_product_details_whatever_the_handle_shape() throws {
        let cases: [(link: String, handle: String)] = [
            ("\(Self.httpUrl)/product/women/dresses/red-midi-dress", "women/dresses/red-midi-dress"),
            ("\(Self.httpUrl)/product/t-shirt", "t-shirt"),
        ]

        try assertProductDetail(cases)
    }

    /// The Swing tag prints an https link on the BFF port, so the chain must accept that shape too.
    func test_printed_alfie_code_opens_product_details_with_handle_and_sku() throws {
        let testUrl = try XCTUnwrap(URL(string: "https://localhost:4000/product/mens/jeans/slim-indigo?sku=SKU-42"))

        let type = sut.deepLinkType(testUrl)

        guard case .productDetail(let handle, _, let query) = type else {
            return XCTFail("Expected Product Details, got \(String(describing: type))")
        }
        XCTAssertEqual(handle, "mens/jeans/slim-indigo")
        XCTAssertEqual(query?["sku"], "SKU-42")
    }

    func test_printed_wishlist_code_opens_the_wishlist() throws {
        let testUrl = try XCTUnwrap(URL(string: "https://localhost:4000/wishlist"))

        let type = sut.deepLinkType(testUrl)

        guard case .wishlist = type else {
            return XCTFail("Expected the wishlist, got \(String(describing: type))")
        }
    }

    func test_printed_help_page_code_falls_through_to_the_web_view() throws {
        let testUrl = try XCTUnwrap(URL(string: "https://localhost:4000/help/returns"))

        let type = sut.deepLinkType(testUrl)

        guard case .webView = type else {
            return XCTFail("Expected the web view, got \(String(describing: type))")
        }
    }

    func test_codes_from_outside_alfie_open_no_in_app_screen() throws {
        let links = ["https://example.com/not-an-alfie-code", "5901234123457"]

        for link in links {
            let testUrl = try XCTUnwrap(URL(string: link))

            let type = sut.deepLinkType(testUrl)

            XCTAssertFalse(opensInAppScreen(type), "\(link) resolved to \(String(describing: type))")
        }
    }

    func test_non_product_link_falls_through_to_the_web_view() throws {
        let testUrl = try XCTUnwrap(URL(string: "\(Self.httpUrl)/some/marketing/page"))

        guard case .webView = sut.deepLinkType(testUrl) else {
            XCTFail("Expected \(testUrl) to fall through to the web view")
            return
        }
    }

    // MARK: - Helpers

    private func opensInAppScreen(_ type: DeepLink.LinkType?) -> Bool {
        switch type {
        case .productDetail, .wishlist: true
        default: false
        }
    }

    private func assertProductDetail(
        _ cases: [(link: String, handle: String)],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        for testCase in cases {
            let testUrl = try XCTUnwrap(URL(string: testCase.link), file: file, line: line)

            guard case .productDetail(let handle, _, _) = sut.deepLinkType(testUrl) else {
                XCTFail("Expected \(testUrl) to open the Product Details page", file: file, line: line)
                continue
            }
            XCTAssertEqual(handle, testCase.handle, "handle for \(testCase.link)", file: file, line: line)
        }
    }
}
