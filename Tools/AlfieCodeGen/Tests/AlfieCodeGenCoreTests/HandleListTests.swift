import Foundation
import Testing
@testable import AlfieCodeGenCore

@Suite("HandleList")
struct HandleListTests {
    @Test("a handle per line, blank lines and comments ignored")
    func parsesPlainList() throws {
        let codes = try HandleList.parse("""
        # demo products
        mens-jeans-slim-indigo

        womens-coat-wool-camel
        """)

        #expect(codes == [
            AlfieCode(handle: "mens-jeans-slim-indigo"),
            AlfieCode(handle: "womens-coat-wool-camel"),
        ])
    }

    @Test("an optional SKU follows the handle after a comma")
    func parsesOptionalSKU() throws {
        let codes = try HandleList.parse("mens-jeans-slim-indigo , SKU-8842")

        #expect(codes == [AlfieCode(handle: "mens-jeans-slim-indigo", sku: "SKU-8842")])
    }

    @Test("a multi-segment handle is a handle, not two fields")
    func parsesMultiSegmentHandle() throws {
        let codes = try HandleList.parse("mens/jeans/slim-indigo")

        #expect(codes == [AlfieCode(handle: "mens/jeans/slim-indigo")])
    }

    @Test("a list with nothing to print is an error, not an empty run")
    func emptyListThrows() {
        #expect(throws: AlfieCodeError.emptyList) {
            try HandleList.parse("""
            # nothing but comments

            """)
        }
    }

    @Test("a malformed line names its line number and what was wrong", arguments: [
        "mens jeans slim",           // whitespace inside a handle
        "mens-jeans?sku=1",          // URL punctuation
        "/mens-jeans",               // leading slash
        "mens-jeans/",               // trailing slash
        "mens//jeans",               // empty path segment
        "mens-jeans,",               // comma with no SKU
        "mens-jeans,SKU-1,extra",    // a third field
        ",SKU-1",                    // no handle
    ])
    func malformedLineThrows(line: String) {
        do {
            _ = try HandleList.parse("ok-handle\n\(line)")
            Issue.record("expected a failure for \(line)")
        } catch let error as AlfieCodeError {
            guard case .malformedLine(let number, let text, _) = error else {
                Issue.record("expected .malformedLine, got \(error)")
                return
            }
            #expect(number == 2)
            #expect(text == line)
            #expect(!error.description.isEmpty)
        } catch {
            Issue.record("unexpected error \(error)")
        }
    }

    @Test("two entries that would overwrite one another are rejected")
    func duplicateEntriesThrow() {
        #expect(throws: AlfieCodeError.self) {
            try HandleList.parse("mens-jeans-slim-indigo\nmens-jeans-slim-indigo")
        }
    }

    @Test("two different handles that would share one file name are rejected")
    func collidingFileNamesThrow() {
        // Both slug to mens-jeans-slim-indigo.png, so one would silently overwrite the other.
        #expect(throws: AlfieCodeError.duplicateEntry(fileName: "mens-jeans-slim-indigo.png")) {
            try HandleList.parse("mens-jeans-slim-indigo\nmens/jeans/slim-indigo")
        }
    }

    @Test("the same handle printed for two SKUs is allowed")
    func sameHandleDifferentSKUs() throws {
        let codes = try HandleList.parse("mens-jeans,SKU-1\nmens-jeans,SKU-2")

        #expect(codes.count == 2)
    }
}
