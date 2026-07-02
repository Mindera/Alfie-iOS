import Foundation
import Testing
@testable import DesignTokenGenCore

private func fixtureURL() throws -> URL {
    if let url = Bundle.module.url(forResource: "mini", withExtension: nil, subdirectory: "Fixtures") {
        return url
    }
    return Bundle.module.resourceURL!.appendingPathComponent("Fixtures/mini")
}

private func tok(_ name: String, _ value: TokenValue, file: String) -> Token {
    Token(name: name, type: "x", value: value, file: file)
}

private func emptyResolver(_ loaded: LoadedTokens, maxDepth: Int = 32) -> Resolver {
    Resolver(loaded: loaded, cycleAllowlist: .init(edges: []), brokenRefAllowlist: .init(missingTargets: []), maxDepth: maxDepth)
}

@Suite("Generator.run (disk)")
struct GeneratorRunTests {
    @Test("run cleans pre-existing *+Generated.swift before writing the fresh set (anti-orphan)")
    func cleansStaleFiles() throws {
        let out = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: out) }
        let stale = out.appendingPathComponent("Legacy+Generated.swift")
        try "// orphaned".write(to: stale, atomically: true, encoding: .utf8)

        let result = try Generator.run(inputDirectory: fixtureURL(), outputDirectory: out)

        #expect(!FileManager.default.fileExists(atPath: stale.path))
        #expect(result.writtenFiles == ["Primitives+Generated.swift", "Sizing+Generated.swift", "Theme+Generated.swift", "ThemeColours+Generated.swift", "Typography+Generated.swift"])
        #expect(FileManager.default.fileExists(atPath: out.appendingPathComponent("Theme+Generated.swift").path))
    }
}

@Suite("Resolver depth")
struct ResolverDepthTests {
    @Test("a reference chain exceeding maxDepth throws referenceTooDeep")
    func tooDeep() {
        let map = ["a": tok("a", .reference("b"), file: "f"),
                   "b": tok("b", .reference("c"), file: "f"),
                   "c": tok("c", .color(components: [0, 0, 0]), file: "f")]
        let r = emptyResolver(LoadedTokens(map: map, primitiveValues: [:], loadedFiles: ["f"]), maxDepth: 1)
        #expect(throws: DesignTokenError.self) { _ = try r.resolvedConcrete("a") }
    }
}

@Suite("Value parsing edges")
struct ValueParsingTests {
    @Test("unknown $type throws malformedToken")
    func unknownType() {
        #expect(throws: DesignTokenError.self) {
            _ = try TokenLoader.parseValue(type: "shadow", raw: "anything", name: "x")
        }
    }

    @Test("color alpha key folds into a 4th opacity component")
    func colorAlphaKey() throws {
        let raw: [String: Any] = ["colorSpace": "srgb", "components": [1, 1, 1], "alpha": 0]
        #expect(try TokenLoader.parseValue(type: "color", raw: raw, name: "x") == .color(components: [1, 1, 1, 0]))
    }

    @Test("string $value that isn't a String throws (no silent empty string)")
    func stringNonStringThrows() {
        #expect(throws: DesignTokenError.self) {
            _ = try TokenLoader.parseValue(type: "string", raw: 5, name: "x")
        }
    }

    @Test("a configured collection missing its expected mode fails fast")
    func missingManifestModeThrows() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        // `system` is configured to require the `ios` mode, but only `android` is present.
        let manifest = #"{"collections":{"system":{"modes":{"android":["system.android.tokens.json"]}}}}"#
        let url = dir.appendingPathComponent("manifest.json")
        try manifest.write(to: url, atomically: true, encoding: .utf8)
        #expect(throws: DesignTokenError.self) { _ = try TokenLoader.selectedFiles(manifestURL: url) }
    }

    @Test("a collection missing its `modes` dictionary fails fast")
    func missingModesDictionaryThrows() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let manifest = #"{"collections":{"theme":{"notModes":{}}}}"#
        let url = dir.appendingPathComponent("manifest.json")
        try manifest.write(to: url, atomically: true, encoding: .utf8)
        #expect(throws: DesignTokenError.self) { _ = try TokenLoader.selectedFiles(manifestURL: url) }
    }

    @Test("fontFamily array takes the first family; empty array throws")
    func fontFamilyArray() throws {
        #expect(try TokenLoader.parseValue(type: "fontFamily", raw: ["Libre", "Arial"], name: "x") == .fontFamily("Libre"))
        #expect(throws: DesignTokenError.self) {
            _ = try TokenLoader.parseValue(type: "fontFamily", raw: [String](), name: "x")
        }
    }

    @Test("referenceTarget unwraps braces and rejects non-references", arguments: [
        ("{spacing-4}", "spacing-4"), ("plain", String?.none), ("{}", nil), ("{a", nil), ("a}", nil),
    ])
    func referenceTargetParsing(input: String, expected: String?) {
        #expect(TokenLoader.referenceTarget(input) == expected)
    }

    @Test("named and numeric font weights map to the CSS scale", arguments: [
        (TokenValue.FontWeight.named("Thin"), 100), (.named("light"), 300), (.named("Regular"), 400),
        (.named("Medium"), 500), (.named("SemiBold"), 600), (.named("Heavy"), 900),
        (.named("nonsense"), 400), (.numeric(550), 550),
    ])
    func fontWeightCSSValue(weight: TokenValue.FontWeight, expected: Int) {
        #expect(weight.cssValue == expected)
    }
}

@Suite("Color literal")
struct ColorLiteralTests {
    // Colour literals live in the ThemeColours palette layer (Primitives.Colours forwards to it).
    private func emitPalette(_ comps: [Double]) throws -> String {
        let token = tok("colours-x-1", .color(components: comps), file: ".primitives.x")
        let loaded = LoadedTokens(map: ["colours-x-1": token], primitiveValues: ["colours-x-1": token], loadedFiles: [".primitives.x"])
        return try Emitter(loaded: loaded, resolver: emptyResolver(loaded)).emit()["ThemeColours+Generated.swift"]!
    }

    @Test("4-component color carries its alpha through to opacity")
    func alphaPreserved() throws {
        #expect(try emitPalette([0.1, 0.2, 0.3, 0.5]).contains("opacity: 0.5"))
    }

    @Test("3-component color defaults opacity to 1.0")
    func opacityDefault() throws {
        #expect(try emitPalette([0.1, 0.2, 0.3]).contains("opacity: 1.0"))
    }

    @Test("color with fewer than 3 components is rejected")
    func tooFewComponents() {
        #expect(throws: DesignTokenError.self) { _ = try emitPalette([0, 0]) }
    }
}

@Suite("Emit edge cases")
struct EmitEdgeTests {
    private func emit(_ loaded: LoadedTokens, broken: Set<String> = []) throws -> [String: String] {
        let resolver = Resolver(loaded: loaded, cycleAllowlist: .init(edges: []), brokenRefAllowlist: .init(missingTargets: broken))
        return try Emitter(loaded: loaded, resolver: resolver).emit()
    }

    @Test("string-valued literals are escaped so special characters can't break the Swift")
    func escapesStringLiterals() throws {
        let weird = "Wei\"rd\\Font"
        let t = tok("typography-font-family-weird", .fontFamily(weird), file: ".primitives.x")
        let loaded = LoadedTokens(map: ["typography-font-family-weird": t], primitiveValues: ["typography-font-family-weird": t], loadedFiles: [".primitives.x"])
        let primitives = try emit(loaded)["Primitives+Generated.swift"]!
        #expect(primitives.contains(String(reflecting: weird)))   // properly escaped Swift literal
    }

    @Test("an emitted token resolving to an allow-listed broken ref throws a clear error")
    func brokenRefReachingOutputThrows() {
        // theme token → {ghost}; ghost is missing but allow-listed → no concrete value to emit.
        let theme = tok("surface-x", .reference("ghost"), file: "theme.x")
        let loaded = LoadedTokens(map: ["surface-x": theme], primitiveValues: [:], loadedFiles: ["theme.x"])
        #expect(throws: DesignTokenError.self) { _ = try emit(loaded, broken: ["ghost"]) }
    }
}
