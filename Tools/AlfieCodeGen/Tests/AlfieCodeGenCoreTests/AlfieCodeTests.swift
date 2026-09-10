import Foundation
import Testing
@testable import AlfieCodeGenCore

@Suite("AlfieCode")
struct AlfieCodeTests {
    @Test("the link carries the handle on the product path")
    func linkWithoutSKU() throws {
        let url = try AlfieCode(handle: "mens-jeans-slim-indigo").url()

        #expect(url.absoluteString == "https://localhost:4000/product/mens-jeans-slim-indigo")
    }

    @Test("a supplied SKU rides along as a query parameter")
    func linkWithSKU() throws {
        let url = try AlfieCode(handle: "mens-jeans-slim-indigo", sku: "SKU-8842").url()

        #expect(url.absoluteString == "https://localhost:4000/product/mens-jeans-slim-indigo?sku=SKU-8842")
    }

    @Test("a multi-segment handle keeps its slashes as path segments")
    func linkWithMultiSegmentHandle() throws {
        let url = try AlfieCode(handle: "mens/jeans/slim-indigo").url()

        #expect(url.absoluteString == "https://localhost:4000/product/mens/jeans/slim-indigo")
    }

    @Test("a SKU needing encoding is percent-encoded")
    func linkWithEncodedSKU() throws {
        let url = try AlfieCode(handle: "mens-jeans", sku: "A&B 1").url()

        #expect(url.absoluteString == "https://localhost:4000/product/mens-jeans?sku=A%26B%201")
    }

    @Test("every link is on the host the app already accepts")
    func linkHost() throws {
        let url = try AlfieCode(handle: "mens-jeans").url()

        #expect(url.scheme == "https")
        #expect(url.host == "localhost")
        #expect(url.port == 4000)
    }

    @Test("a printable handle has no problem")
    func noProblem() {
        #expect(AlfieCode(handle: "mens/jeans/slim-indigo", sku: "SKU-8842").problem == nil)
    }

    @Test("each rejected handle names the rule that rejected it", arguments: zip(
        ["", "mens jeans", "/mens-jeans", "mens-jeans/", "mens//jeans"],
        [
            AlfieCode.Problem.noHandle,
            .disallowedCharacter(" "),
            .slashAtEdge,
            .slashAtEdge,
            .emptyPathSegment,
        ]
    ))
    func problems(handle: String, expected: AlfieCode.Problem) {
        #expect(AlfieCode(handle: handle).problem == expected)
    }

    @Test("file names stay distinct and filesystem-safe")
    func fileNames() {
        #expect(AlfieCode(handle: "mens/jeans/slim-indigo").fileName == "mens-jeans-slim-indigo.png")
        #expect(AlfieCode(handle: "mens-jeans", sku: "SKU/8842").fileName == "mens-jeans--sku-SKU-8842.png")
    }
}
