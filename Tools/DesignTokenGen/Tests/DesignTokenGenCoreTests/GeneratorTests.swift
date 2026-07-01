import Foundation
import Testing
@testable import DesignTokenGenCore

private func miniURL() throws -> URL {
    if let url = Bundle.module.url(forResource: "mini", withExtension: nil, subdirectory: "Fixtures") {
        return url
    }
    return Bundle.module.resourceURL!.appendingPathComponent("Fixtures/mini")
}

private func token(_ name: String, _ value: TokenValue, file: String) -> Token {
    Token(name: name, type: "x", value: value, file: file)
}

@Suite("TokenLoader")
struct TokenLoaderTests {
    @Test("manifest mode-selection loads the iOS subset, skips android/large/documentation")
    func modeSelection() throws {
        let files = try TokenLoader.selectedFiles(manifestURL: miniURL().appendingPathComponent("manifest.json"))
        #expect(files.contains("system.ios.tokens.json"))
        #expect(files.contains("screen-size.small-(s).tokens.json"))
        #expect(files.contains("typography.styles.tokens.json"))
        #expect(!files.contains("system.android.tokens.json"))
        #expect(!files.contains("screen-size.large-(l).tokens.json"))
        #expect(!files.contains(".documentation.mode-1.tokens.json"))
    }

    @Test("parses color components, px dimension, composite typography")
    func parsesValues() throws {
        let loaded = try TokenLoader.load(inputDirectory: miniURL())
        #expect(loaded.map["colours-neutrals-0"]?.value == .color(components: [1, 1, 1]))
        #expect(loaded.map["spacing-spacing-16"]?.value == .dimension(value: 16, unit: "px"))
        if case .typography = loaded.map["display-large"]?.value {} else { Issue.record("display-large not composite") }
    }

    @Test("~~doc- tokens are skipped")
    func skipsDocTokens() throws {
        let loaded = try TokenLoader.load(inputDirectory: miniURL())
        #expect(loaded.map["~~doc-others-token"] == nil)
    }

    @Test("parses hex colour strings (6- and 8-digit), case-insensitive")
    func parsesHexColours() throws {
        #expect(try TokenLoader.parseValue(type: "color", raw: "#FFFFFF", name: "x") == .color(components: [1, 1, 1]))
        #expect(try TokenLoader.parseValue(type: "color", raw: "#000000", name: "x") == .color(components: [0, 0, 0]))
        #expect(try TokenLoader.parseValue(type: "color", raw: "#ffffff00", name: "x") == .color(components: [1, 1, 1, 0]))
    }

    @Test("invalid hex colour throws")
    func rejectsBadHex() {
        #expect(throws: DesignTokenError.self) {
            _ = try TokenLoader.parseValue(type: "color", raw: "#12", name: "x")
        }
    }

    @Test("non-px dimension unit throws")
    func rejectsNonPxUnit() {
        #expect(throws: DesignTokenError.self) {
            _ = try TokenLoader.parseValue(type: "dimension", raw: ["value": 1, "unit": "rem"], name: "x")
        }
    }
}

@Suite("Resolver")
struct ResolverTests {
    private func resolver(map: [String: Token], primitives: [String: Token] = [:], files: Set<String>,
                          cycles: [CycleAllowlist.Edge] = [], broken: Set<String> = []) -> Resolver {
        Resolver(
            loaded: LoadedTokens(map: map, primitiveValues: primitives, loadedFiles: files),
            cycleAllowlist: CycleAllowlist(edges: cycles),
            brokenRefAllowlist: BrokenRefAllowlist(missingTargets: broken)
        )
    }

    @Test("real export validates clean and warns about the allow-listed cycle")
    func validatesMiniFixture() throws {
        let loaded = try TokenLoader.load(inputDirectory: miniURL())
        let cycles = try CycleAllowlist.load(from: miniURL().appendingPathComponent(".cycle-allowlist.json"))
        let broken = try BrokenRefAllowlist.load(from: miniURL().appendingPathComponent(".broken-ref-allowlist.json"))
        let warnings = try Resolver(loaded: loaded, cycleAllowlist: cycles, brokenRefAllowlist: broken).validate()
        #expect(warnings.contains { $0.contains("resolved to primitive") })
    }

    @Test("missing reference not on allow-list fails")
    func missingRef() {
        let map = ["a": token("a", .reference("ghost"), file: "theme.x")]
        #expect(throws: DesignTokenError.self) {
            try resolver(map: map, files: ["theme.x"]).validate()
        }
    }

    @Test("unexpected cycle not on allow-list fails")
    func unexpectedCycle() {
        let map = ["a": token("a", .reference("b"), file: "f1"),
                   "b": token("b", .reference("a"), file: "f2")]
        #expect(throws: DesignTokenError.self) {
            try resolver(map: map, files: ["f1", "f2"]).validate()
        }
    }

    @Test("allow-listed cycle resolves to its primitive value")
    func allowlistedCycleResolves() throws {
        let map = ["a": token("a", .reference("b"), file: "f1"),
                   "b": token("b", .reference("a"), file: "f2")]
        let primitives = ["a": token("a", .fontFamily("Libre Test"), file: ".primitives.x")]
        let r = resolver(map: map, primitives: primitives, files: ["f1", "f2"],
                         cycles: [.init(file: "f1", token: "a"), .init(file: "f2", token: "b")])
        let warnings = try r.validate()
        #expect(warnings.contains { $0.contains("resolved to primitive") })
    }

    @Test("stale cycle-allow-list entry (in-scope, no real cycle) fails")
    func staleCycleEntry() {
        let map = ["a": token("a", .color(components: [0, 0, 0]), file: "f1")]
        #expect(throws: DesignTokenError.self) {
            try resolver(map: map, files: ["f1"], cycles: [.init(file: "f1", token: "a")]).validate()
        }
    }

    @Test("stale broken-ref-allow-list entry fails")
    func staleBrokenRef() {
        let map = ["a": token("a", .color(components: [0, 0, 0]), file: "f1")]
        #expect(throws: DesignTokenError.self) {
            try resolver(map: map, files: ["f1"], broken: ["never-referenced"]).validate()
        }
    }

    @Test("out-of-scope allow-list entries (unloaded files) are ignored, not stale")
    func outOfScopeIgnored() throws {
        let map = ["a": token("a", .color(components: [0, 0, 0]), file: "f1")]
        // edge pinned to a file we didn't load → must not trip staleness
        try resolver(map: map, files: ["f1"], cycles: [.init(file: "unloaded.json", token: "z")]).validate()
    }
}

@Suite("Emitter")
struct EmitterTests {
    private func emit() throws -> [String: String] { try Generator.emitInMemory(inputDirectory: miniURL()) }

    @Test("primitives emit concrete literals; colours forward to the active theme palette")
    func primitivesLiterals() throws {
        let p = try emit()["Primitives+Generated.swift"]!
        #expect(p.contains("public enum Colours"))
        // Colours are now theme-swappable forwarders, not fixed literals.
        #expect(p.contains("public static var neutrals0: Color { ThemeColours.current.neutrals0 }"))
        #expect(!p.contains("Color(.sRGB"))  // colour literals moved to ThemeColours
        #expect(p.contains("public static let fontFamilyBrand: String = \"Libre Test\""))
    }

    @Test("a primitive that aliases another primitive emits a symbol reference, not a literal")
    func primitiveReferencingPrimitive() throws {
        let p = try emit()["Primitives+Generated.swift"]!
        #expect(p.contains("public static let fontSizeFontSize12 = Primitives.Spacing.spacing12"))
    }

    @Test("semantic theme tokens reference primitives, never inline a color literal")
    func themeReferenceGraph() throws {
        let t = try emit()["Theme+Generated.swift"]!
        #expect(t.contains("public static let surfaceBackgroundPrimary = Primitives.Colours.neutrals0"))
        #expect(!t.contains("Color(.sRGB"))  // reference-graph AC: no hardcoded hex/components in semantic layer
    }

    @Test("sizing mixes primitive references and concrete literals")
    func sizingMixed() throws {
        let s = try emit()["Sizing+Generated.swift"]!
        #expect(s.contains("public static let radiusSoft: CGFloat = Primitives.Spacing.spacing4"))
        #expect(s.contains("public static let radiusRounded: CGFloat = CGFloat(1000.0)"))
    }

    @Test("typography emits nested styles referencing primitives; cycle field resolves; doc skipped")
    func typographyComposite() throws {
        let t = try emit()["Typography+Generated.swift"]!
        #expect(t.contains("public enum Display"))
        #expect(t.contains("public enum Heading"))
        #expect(t.contains("public init("))   // public memberwise init so the type is usable cross-module
        #expect(t.contains("public static let large = TypographyStyle("))
        #expect(t.contains("fontFamily: Primitives.Typography.fontFamilyBrand"))  // resolved through the allow-listed cycle
        #expect(t.contains("fontSize: Primitives.Typography.fontSizeFontSize40"))
        #expect(t.contains("fontWeight: 400"))   // "Regular"
        #expect(t.contains("fontWeight: 500"))   // "Medium"
        #expect(!t.contains("doc"))              // ~~doc- token excluded
    }

    @Test("every generated file carries the auto-generated + swiftlint-disable header, no timestamp")
    func headerStamp() throws {
        for (_, content) in try emit() {
            #expect(content.contains("AUTO-GENERATED"))
            #expect(content.contains("swiftlint:disable all"))
        }
    }

    @Test("output is byte-identical across runs (deterministic)")
    func deterministic() throws {
        #expect(try emit() == emit())
    }

    // MARK: - Multi-theme colours

    private func colourToken(_ name: String, _ comps: [Double], file: String) -> Token {
        Token(name: name, type: "color", value: .color(components: comps), file: file)
    }

    private func twoThemeLoaded(slateComplete: Bool = true) -> LoadedTokens {
        let alfie = [
            "colours-neutrals-0": colourToken("colours-neutrals-0", [1, 1, 1], file: ".primitives.alfie-theme.tokens.json"),
            "colours-neutrals-100": colourToken("colours-neutrals-100", [0.9, 0.9, 0.9], file: ".primitives.alfie-theme.tokens.json"),
        ]
        var slate = ["colours-neutrals-0": colourToken("colours-neutrals-0", [0, 0, 0], file: ".primitives.selffridge-theme.tokens.json")]
        if slateComplete {
            slate["colours-neutrals-100"] = colourToken("colours-neutrals-100", [0.1, 0.1, 0.1], file: ".primitives.selffridge-theme.tokens.json")
        }
        return LoadedTokens(
            map: alfie, primitiveValues: alfie, loadedFiles: [".primitives.alfie-theme.tokens.json"],
            colourThemes: ["alfie-theme": alfie, "selffridge-theme": slate], baseTheme: "alfie-theme"
        )
    }

    private func emit(_ loaded: LoadedTokens) throws -> [String: String] {
        let resolver = Resolver(loaded: loaded, cycleAllowlist: .init(edges: []), brokenRefAllowlist: .init(missingTargets: []))
        return try Emitter(loaded: loaded, resolver: resolver).emit()
    }

    @Test("multi-theme: ThemeColours emits a palette + AppTheme case per theme; Primitives.Colours forwards")
    func multiThemeColours() throws {
        let files = try emit(twoThemeLoaded())
        let tc = files["ThemeColours+Generated.swift"]!
        #expect(tc.contains("public struct ColourPalette"))
        #expect(tc.contains("public static let alfie = ColourPalette("))
        #expect(tc.contains("public static let selffridge = ColourPalette("))
        #expect(tc.contains("public enum AppTheme: String, CaseIterable"))
        #expect(tc.contains("case alfie = \"alfie-theme\""))
        #expect(tc.contains("case selffridge = \"selffridge-theme\""))
        #expect(tc.contains("public static var current: ColourPalette = alfie"))
        // Distinct literals per theme.
        #expect(tc.contains("Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)"))
        #expect(tc.contains("Color(.sRGB, red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0)"))
        // Call sites keep reading Primitives.Colours, which now forwards to the active palette.
        #expect(files["Primitives+Generated.swift"]!.contains("public static var neutrals0: Color { ThemeColours.current.neutrals0 }"))
    }

    @Test("multi-theme: a theme missing a base colour fails the build (schema drift guard)")
    func multiThemeMissingColourThrows() {
        #expect(throws: DesignTokenError.self) {
            _ = try emit(twoThemeLoaded(slateComplete: false))
        }
    }

    @Test("colour-free input emits a compilable empty ThemeColours (case-less enum, no raw type)")
    func colourFreeInputEmitsValidEmptyThemeColours() throws {
        let fontToken = Token(name: "typography-font-family-x", type: "fontFamily", value: .fontFamily("X"), file: ".primitives.x")
        let loaded = LoadedTokens(
            map: ["typography-font-family-x": fontToken],
            primitiveValues: ["typography-font-family-x": fontToken],
            loadedFiles: [".primitives.x"]
        )
        let tc = try emit(loaded)["ThemeColours+Generated.swift"]!
        #expect(tc.contains("public enum AppTheme {"))
        #expect(!tc.contains("public enum AppTheme: String"))   // a no-case enum can't declare a raw type
    }
}
