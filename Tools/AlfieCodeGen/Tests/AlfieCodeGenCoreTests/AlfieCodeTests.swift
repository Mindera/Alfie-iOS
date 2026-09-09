import Foundation
import Testing
@testable import AlfieCodeGenCore

@Suite("AlfieCode")
struct AlfieCodeTests {
    @Test("the link carries the handle on the product path")
    func linkWithoutSKU() throws {
        let url = try AlfieCode(handle: "mens-jeans-slim-indigo").url(baseURL: AlfieCode.defaultBaseURL)

        #expect(url.absoluteString == "https://localhost:4000/product/mens-jeans-slim-indigo")
    }

    @Test("a supplied SKU rides along as a query parameter")
    func linkWithSKU() throws {
        let url = try AlfieCode(handle: "mens-jeans-slim-indigo", sku: "SKU-8842")
            .url(baseURL: AlfieCode.defaultBaseURL)

        #expect(url.absoluteString == "https://localhost:4000/product/mens-jeans-slim-indigo?sku=SKU-8842")
    }

    @Test("a multi-segment handle keeps its slashes as path segments")
    func linkWithMultiSegmentHandle() throws {
        let url = try AlfieCode(handle: "mens/jeans/slim-indigo").url(baseURL: AlfieCode.defaultBaseURL)

        #expect(url.absoluteString == "https://localhost:4000/product/mens/jeans/slim-indigo")
    }

    @Test("a SKU needing encoding is percent-encoded")
    func linkWithEncodedSKU() throws {
        let url = try AlfieCode(handle: "mens-jeans", sku: "A&B 1").url(baseURL: AlfieCode.defaultBaseURL)

        #expect(url.absoluteString == "https://localhost:4000/product/mens-jeans?sku=A%26B%201")
    }

    @Test("a base URL with a path prefix is respected")
    func linkWithPrefixedBaseURL() throws {
        let base = URL(string: "https://alfie.example.com/uk")!
        let url = try AlfieCode(handle: "mens-jeans").url(baseURL: base)

        #expect(url.absoluteString == "https://alfie.example.com/uk/product/mens-jeans")
    }

    @Test("the default base URL is the host the app already accepts")
    func defaultBaseURL() {
        #expect(AlfieCode.defaultBaseURL.absoluteString == "https://localhost:4000")
    }

    @Test("file names stay distinct and filesystem-safe")
    func fileNames() {
        #expect(AlfieCode(handle: "mens/jeans/slim-indigo").fileName == "mens-jeans-slim-indigo.png")
        #expect(AlfieCode(handle: "mens-jeans", sku: "SKU/8842").fileName == "mens-jeans--sku-SKU-8842.png")
    }
}
