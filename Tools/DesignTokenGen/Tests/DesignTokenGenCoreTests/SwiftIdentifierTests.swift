import Testing
@testable import DesignTokenGenCore

@Suite("SwiftIdentifier")
struct SwiftIdentifierTests {
    @Test("hyphenated segments → lowerCamelCase")
    func camelCases() {
        #expect(SwiftIdentifier.make("surface-background-primary") == "surfaceBackgroundPrimary")
        #expect(SwiftIdentifier.make("body-x-small") == "bodyXSmall")
    }

    @Test("numeric leaf segments glue to the previous word")
    func numericSegments() {
        #expect(SwiftIdentifier.make("colours-neutrals-800", dropPrefix: "colours") == "neutrals800")
        #expect(SwiftIdentifier.make("spacing-spacing-0", dropPrefix: "spacing") == "spacing0")
    }

    @Test("leading-digit identifier gets prefixed so it compiles")
    func leadingDigit() {
        #expect(SwiftIdentifier.make("2xl") == "_2xl")
    }

    @Test("Swift keywords are back-tick escaped")
    func keywordEscape() {
        #expect(SwiftIdentifier.make("default") == "`default`")
        #expect(SwiftIdentifier.make("repeat") == "`repeat`")
    }

    @Test("distinct names colliding to one identifier throws")
    func collisionThrows() {
        #expect(throws: DesignTokenError.self) {
            // "a-b" and "a--b" (empty middle segment) both → "aB"
            try SwiftIdentifier.assertNoCollisions(["a-b", "a--b"])
        }
    }

    @Test("non-colliding names pass")
    func noCollision() throws {
        try SwiftIdentifier.assertNoCollisions(["display-large", "display-medium", "heading-small"])
    }
}
