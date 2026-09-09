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

    func test_multi_segment_handle_opens_product_details() throws {
        try assertProductDetail("\(Self.httpUrl)/product/women/dresses/red-midi-dress",
                                handle: "women/dresses/red-midi-dress")
    }

    func test_single_segment_handle_opens_product_details() throws {
        try assertProductDetail("\(Self.httpUrl)/product/t-shirt", handle: "t-shirt")
    }

    func test_non_product_link_falls_through_to_the_web_view() throws {
        let testUrl = try XCTUnwrap(URL(string: "\(Self.httpUrl)/some/marketing/page"))

        guard case .webView = sut.deepLinkType(testUrl) else {
            XCTFail("Expected \(testUrl) to fall through to the web view")
            return
        }
    }

    // MARK: - Helpers

    /// The `slug` label is the pre-existing one on `LinkType`; the value it carries is a Handle.
    private func assertProductDetail(_ link: String, handle expectedHandle: String) throws {
        let testUrl = try XCTUnwrap(URL(string: link))

        guard case .productDetail(let handle, _, _) = sut.deepLinkType(testUrl) else {
            XCTFail("Expected \(testUrl) to open the Product Details page")
            return
        }

        XCTAssertEqual(handle, expectedHandle)
    }
}
