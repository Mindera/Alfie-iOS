import Foundation

/// A single design token's concrete value, parsed from a DTCG `$value`.
/// Reference values (`"{name}"`) are kept as `.reference` until the resolver walks them.
public enum TokenValue: Equatable {
    case color(components: [Double])          // sRGB, 3 or 4 (alpha) components in 0...1
    case dimension(value: Double, unit: String)
    case fontFamily(String)
    case fontWeight(FontWeight)               // CSS 100–900, or named "Regular"/"Medium"
    case string(String)
    indirect case typography(Typography)      // indirect: Typography stores TokenValue (recursive)
    case reference(String)                    // "{token-name}", target name only

    /// Composite typography value; each sub-field is itself a `TokenValue`
    /// (usually `.reference`, except `fontWeight` which the export inlines).
    public struct Typography: Equatable {
        public let fontFamily: TokenValue
        public let fontWeight: TokenValue
        public let fontSize: TokenValue
        public let lineHeight: TokenValue
        public let letterSpacing: TokenValue
    }

    /// `fontWeight` is either a CSS number (100–900) or a Figma style name.
    /// Named weights map to the CSS scale per the token repo's broken-ref allowlist fix.
    public enum FontWeight: Equatable {
        case numeric(Int)
        case named(String)

        public var cssValue: Int {
            switch self {
            case .numeric(let n): return n
            case .named(let name):
                switch name.lowercased() {
                case "thin": return 100
                case "extralight", "ultralight": return 200
                case "light": return 300
                case "regular", "normal": return 400
                case "medium": return 500
                case "semibold", "demibold": return 600
                case "bold": return 700
                case "extrabold", "ultrabold": return 800
                case "black", "heavy": return 900
                default: return 400
                }
            }
        }
    }
}

/// A token plus provenance (the file it was last defined in — needed to pin cycle-allowlist edges).
public struct Token: Equatable {
    public let name: String       // full hyphenated DTCG name, e.g. "colours-neutrals-800"
    public let type: String       // DTCG `$type`
    public let value: TokenValue
    public let file: String       // source filename, e.g. "system.ios.tokens.json"
}

public enum DesignTokenError: Error, CustomStringConvertible, Equatable {
    case manifestNotFound(String)
    case fileNotFound(String)
    case malformedToken(name: String, reason: String)
    case unpinnedMultiModeCollection(collection: String, modes: [String])   // manifest is valid; iOS codegen has no pin for it
    case unknownDimensionUnit(token: String, unit: String)
    case missingReference(token: String, target: String)         // not on broken-ref allowlist
    case brokenReferenceInOutput(target: String)                 // allow-listed broken ref reached an emitted surface
    case unexpectedCycle(file: String, token: String)            // not on cycle allowlist
    case staleCycleAllowlistEntry(file: String, token: String)   // allow-listed but no such cycle
    case staleBrokenRefAllowlistEntry(target: String)
    case referenceTooDeep(token: String)
    case identifierCollision(swift: String, names: [String])

    public var description: String {
        switch self {
        case .manifestNotFound(let p): return "manifest.json not found at \(p)"
        case .fileNotFound(let p): return "token file not found: \(p)"
        case .malformedToken(let n, let r): return "malformed token '\(n)': \(r)"
        case .unpinnedMultiModeCollection(let c, let m): return "collection '\(c)' has multiple modes [\(m.joined(separator: ", "))] but no pinned mode — add one to TokenLoader.modeForCollection to select the iOS mode"
        case .unknownDimensionUnit(let t, let u): return "token '\(t)': unsupported dimension unit '\(u)' (only 'px')"
        case .missingReference(let t, let g): return "token '\(t)' references missing target '{\(g)}' (not on broken-ref allowlist)"
        case .brokenReferenceInOutput(let g): return "an emitted token resolves to allow-listed broken ref '{\(g)}' — it has no concrete value to emit"
        case .unexpectedCycle(let f, let t): return "unexpected reference cycle at (\(f), \(t)) — not on cycle allowlist"
        case .staleCycleAllowlistEntry(let f, let t): return "stale cycle-allowlist entry (\(f), \(t)) — no such cycle in export"
        case .staleBrokenRefAllowlistEntry(let t): return "stale broken-ref-allowlist entry '\(t)' — target resolves or is unreferenced"
        case .referenceTooDeep(let t): return "token '\(t)': reference chain exceeds max depth"
        case .identifierCollision(let s, let n): return "Swift identifier collision '\(s)' from names: \(n.joined(separator: ", "))"
        }
    }
}
