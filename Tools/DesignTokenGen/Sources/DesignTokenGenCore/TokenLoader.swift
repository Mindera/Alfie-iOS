import Foundation

/// Reads `manifest.json`, selects the iOS-relevant mode per multi-mode collection, parses the
/// chosen DTCG files into one flat `name → Token` map. References resolve by name, not path, so a
/// flat map is correct (per the token repo's contract). Mode-selection is what keeps the duplicate
/// names across `system.{ios,android,web}` / `screen-size.*` from colliding.
public struct LoadedTokens {
    public let map: [String: Token]              // working map, last-writer-wins across files
    public let primitiveValues: [String: Token]  // concrete values from .primitives (cycle fallback)
    public let loadedFiles: Set<String>          // filenames actually parsed (scopes allowlist checks)
    // Per-theme colour palettes: each `.primitives` mode parsed into its own colour set (incl. base).
    // Colours + font families vary across themes; the base theme drives `map`/`primitiveValues` for
    // everything else.
    public let colourThemes: [String: [String: Token]]
    // Per-theme font-family palettes: each `.primitives` mode's `fontFamily` primitives. A theme may
    // override only some families; undefined ones fall back to the base theme at emit time.
    public let fontThemes: [String: [String: Token]]
    public let baseTheme: String                 // theme id (mode name) driving `map`/`primitiveValues`

    public init(
        map: [String: Token],
        primitiveValues: [String: Token],
        loadedFiles: Set<String>,
        colourThemes: [String: [String: Token]] = [:],
        fontThemes: [String: [String: Token]] = [:],
        baseTheme: String = TokenLoader.baseTheme
    ) {
        self.map = map
        self.primitiveValues = primitiveValues
        self.loadedFiles = loadedFiles
        self.colourThemes = colourThemes
        self.fontThemes = fontThemes
        self.baseTheme = baseTheme
    }
}

public enum TokenLoader {
    /// iOS mode choices for the two multi-mode collections (PLAN.md Q3: mobile uses Small at codegen).
    static let modeForCollection: [String: String] = [
        "system": "ios",
        "screen-size": "small-(s)",
    ]
    static let documentationPrefix = "~~doc-"
    /// The `.primitives` collection can expose several theme modes that share one schema and differ
    /// only in colour values. The BASE mode drives the resolver map / non-colour tokens; the others
    /// are loaded separately as colour palettes (see `colourThemes`). Kept as a named constant so the
    /// choice is explicit and the loader never merges two primitive themes into one map.
    static let primitivesCollection = ".primitives"
    public static let baseTheme = "alfie-theme"

    public static func load(inputDirectory dir: URL) throws -> LoadedTokens {
        let manifestURL = dir.appendingPathComponent("manifest.json")
        guard FileManager.default.fileExists(atPath: manifestURL.path) else {
            throw DesignTokenError.manifestNotFound(manifestURL.path)
        }
        let files = try selectedFiles(manifestURL: manifestURL)

        var map: [String: Token] = [:]
        var primitiveValues: [String: Token] = [:]
        var loaded: Set<String> = []

        for file in files {
            let url = dir.appendingPathComponent(file)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw DesignTokenError.fileNotFound(url.path)
            }
            let tokens = try parseFile(url: url, file: file)
            for token in tokens {
                map[token.name] = token
                if file.hasPrefix(".primitives") { primitiveValues[token.name] = token }
            }
            loaded.insert(file)
        }

        // Load every `.primitives` theme mode into its own colour palette (colours only). The base
        // mode is also present in `map`/`primitiveValues` above; the extra modes never enter the map
        // (which would clobber via last-writer-wins), so resolution stays anchored to the base theme.
        let primitiveModes = try primitiveThemeModes(manifestURL: manifestURL)
        var colourThemes: [String: [String: Token]] = [:]
        var fontThemes: [String: [String: Token]] = [:]
        for (themeId, themeFiles) in primitiveModes {
            var colours: [String: Token] = [:]
            var fonts: [String: Token] = [:]
            for file in themeFiles {
                let url = dir.appendingPathComponent(file)
                guard FileManager.default.fileExists(atPath: url.path) else {
                    throw DesignTokenError.fileNotFound(url.path)
                }
                for token in try parseFile(url: url, file: file) {
                    if token.value.isColour { colours[token.name] = token }
                    else if case .fontFamily = token.value { fonts[token.name] = token }
                }
            }
            colourThemes[themeId] = colours
            fontThemes[themeId] = fonts
        }
        let base = colourThemes[baseTheme] != nil ? baseTheme : (colourThemes.keys.sorted().first ?? baseTheme)
        return LoadedTokens(
            map: map,
            primitiveValues: primitiveValues,
            loadedFiles: loaded,
            colourThemes: colourThemes,
            fontThemes: fontThemes,
            baseTheme: base
        )
    }

    /// All theme modes declared under the `.primitives` collection → `themeId : [file]`.
    static func primitiveThemeModes(manifestURL: URL) throws -> [String: [String]] {
        let data = try Data(contentsOf: manifestURL)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let collections = root["collections"] as? [String: Any],
              let modes = (collections[primitivesCollection] as? [String: Any])?["modes"] as? [String: Any] else {
            return [:]
        }
        var out: [String: [String]] = [:]
        for (mode, list) in modes {
            out[mode] = (list as? [Any])?.compactMap { $0 as? String } ?? []
        }
        return out
    }

    /// Filenames to load: skip `.documentation`; pick the iOS mode for multi-mode collections;
    /// include single-mode collections and the typography styles.
    static func selectedFiles(manifestURL: URL) throws -> [String] {
        let data = try Data(contentsOf: manifestURL)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DesignTokenError.malformedToken(name: "manifest.json", reason: "not an object")
        }
        var files: [String] = []
        if let collections = root["collections"] as? [String: Any] {
            for (collection, value) in collections {
                if collection == ".documentation" { continue }
                // A collection without a `modes` dictionary is contract drift — fail fast rather than
                // silently dropping its tokens from the generated set.
                guard let modes = (value as? [String: Any])?["modes"] as? [String: Any] else {
                    throw DesignTokenError.malformedToken(name: "manifest.json", reason: "collection '\(collection)' has no 'modes' dictionary")
                }
                let chosen: [Any]
                if collection == primitivesCollection {
                    // Multiple primitive themes share one schema; only the BASE mode feeds the map.
                    // The others are loaded as colour palettes in `load()` — merging them here would
                    // clobber the base values via last-writer-wins.
                    guard let list = (modes[baseTheme] ?? (modes.count == 1 ? modes.values.first : nil)) as? [Any] else {
                        throw DesignTokenError.malformedToken(name: "manifest.json", reason: "collection '.primitives' is missing base mode '\(baseTheme)'")
                    }
                    chosen = list
                } else if let mode = modeForCollection[collection] {
                    // A configured collection MUST expose its expected mode — falling back to an empty
                    // list would silently emit an incomplete token set.
                    guard let list = modes[mode] as? [Any] else {
                        throw DesignTokenError.malformedToken(name: "manifest.json", reason: "collection '\(collection)' is missing expected mode '\(mode)'")
                    }
                    chosen = list
                } else {
                    chosen = modes.values.compactMap { $0 as? [Any] }.flatMap { $0 }
                }
                files.append(contentsOf: chosen.compactMap { $0 as? String })
            }
        }
        if let styles = root["styles"] as? [String: Any] {
            for (_, value) in styles {
                files.append(contentsOf: (value as? [Any])?.compactMap { $0 as? String } ?? [])
            }
        }
        return files.sorted()  // deterministic load order
    }

    static func parseFile(url: URL, file: String) throws -> [Token] {
        let data = try Data(contentsOf: url)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DesignTokenError.malformedToken(name: file, reason: "not an object")
        }
        var tokens: [Token] = []
        try walk(root, prefix: [], file: file, into: &tokens)
        return tokens
    }

    private static func walk(_ node: [String: Any], prefix: [String], file: String, into tokens: inout [Token]) throws {
        for (key, value) in node {
            guard let child = value as? [String: Any] else { continue }
            let path = prefix + [key]
            let name = path.joined(separator: "-")
            if child["$value"] != nil {
                if name.hasPrefix(documentationPrefix) { continue }  // skip internal Figma docs
                let type = child["$type"] as? String ?? ""
                let parsed = try parseValue(type: type, raw: child["$value"]!, name: name)
                tokens.append(Token(name: name, type: type, value: parsed, file: file))
            } else {
                try walk(child, prefix: path, file: file, into: &tokens)
            }
        }
    }

    static func parseValue(type: String, raw: Any, name: String) throws -> TokenValue {
        if let str = raw as? String, let target = referenceTarget(str) {
            return .reference(target)
        }
        switch type {
        case "color":
            // Colours arrive either as a `{components}` object (Figma export) or a hex string
            // (`"#RRGGBB"` / `"#RRGGBBAA"`, used by hand-authored theme files). Reference strings
            // (`"{token}"`) are already short-circuited above.
            if let hex = raw as? String {
                return .color(components: try hexComponents(hex, name: name))
            }
            guard let dict = raw as? [String: Any], let rawComponents = dict["components"] as? [Any] else {
                throw DesignTokenError.malformedToken(name: name, reason: "color missing components")
            }
            var components = rawComponents.compactMap { ($0 as? NSNumber)?.doubleValue }
            // Alpha arrives either as a 4th component or a separate `alpha` key — the Figma export
            // uses the latter (e.g. transparent = components [1,1,1] + alpha 0). Fold it in as opacity.
            if components.count == 3, let alpha = (dict["alpha"] as? NSNumber)?.doubleValue {
                components.append(alpha)
            }
            return .color(components: components)
        case "dimension":
            guard let dict = raw as? [String: Any],
                  let value = (dict["value"] as? NSNumber)?.doubleValue,
                  let unit = dict["unit"] as? String else {
                throw DesignTokenError.malformedToken(name: name, reason: "dimension missing value/unit")
            }
            guard unit == "px" else { throw DesignTokenError.unknownDimensionUnit(token: name, unit: unit) }
            return .dimension(value: value, unit: unit)
        case "fontFamily":
            if let s = raw as? String { return .fontFamily(s) }
            if let arr = raw as? [Any], let first = arr.first as? String { return .fontFamily(first) }
            throw DesignTokenError.malformedToken(name: name, reason: "fontFamily not string/array")
        case "fontWeight":
            if let n = raw as? NSNumber { return .fontWeight(.numeric(n.intValue)) }
            if let s = raw as? String { return .fontWeight(.named(s)) }
            throw DesignTokenError.malformedToken(name: name, reason: "fontWeight not number/string")
        case "string":
            guard let s = raw as? String else {
                throw DesignTokenError.malformedToken(name: name, reason: "string $value is not a String")
            }
            return .string(s)
        case "typography":
            guard let dict = raw as? [String: Any] else {
                throw DesignTokenError.malformedToken(name: name, reason: "typography not an object")
            }
            func sub(_ field: String, _ subtype: String) throws -> TokenValue {
                guard let v = dict[field] else {
                    throw DesignTokenError.malformedToken(name: name, reason: "typography missing \(field)")
                }
                return try parseValue(type: subtype, raw: v, name: "\(name).\(field)")
            }
            return .typography(.init(
                fontFamily: try sub("fontFamily", "fontFamily"),
                fontWeight: try sub("fontWeight", "fontWeight"),
                fontSize: try sub("fontSize", "dimension"),
                lineHeight: try sub("lineHeight", "dimension"),
                letterSpacing: try sub("letterSpacing", "dimension")
            ))
        default:
            throw DesignTokenError.malformedToken(name: name, reason: "unknown $type '\(type)'")
        }
    }

    /// `"{token-name}"` → `"token-name"`, else nil.
    static func referenceTarget(_ raw: String) -> String? {
        guard raw.hasPrefix("{"), raw.hasSuffix("}"), raw.count >= 3 else { return nil }
        return String(raw.dropFirst().dropLast())
    }

    /// `"#RRGGBB"` / `"#RRGGBBAA"` → sRGB components in 0…1 (3 or 4). Case-insensitive.
    static func hexComponents(_ raw: String, name: String) throws -> [Double] {
        var hex = raw.trimmingCharacters(in: .whitespaces)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard (hex.count == 6 || hex.count == 8), hex.allSatisfy(\.isHexDigit) else {
            throw DesignTokenError.malformedToken(name: name, reason: "invalid hex colour '\(raw)'")
        }
        let chars = Array(hex)
        var comps: [Double] = []
        var i = 0
        while i < chars.count {
            let byte = UInt8(String(chars[i]) + String(chars[i + 1]), radix: 16)!
            comps.append(Double(byte) / 255.0)
            i += 2
        }
        return comps  // [r, g, b] or [r, g, b, a]
    }
}
