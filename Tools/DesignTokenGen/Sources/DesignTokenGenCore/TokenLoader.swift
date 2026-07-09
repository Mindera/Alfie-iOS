import Foundation

/// Reads `manifest.json`, selects the iOS-relevant mode per multi-mode collection, parses the
/// chosen DTCG files into one flat `name → Token` map. References resolve by name, not path, so a
/// flat map is correct (per the token repo's contract). Mode-selection is what keeps the duplicate
/// names across `system.{ios,android,web}` / `screen-size.*` from colliding.
public struct LoadedTokens {
    public let map: [String: Token]              // working map, last-writer-wins across files
    public let primitiveValues: [String: Token]  // concrete values from .primitives (cycle fallback)
    public let loadedFiles: Set<String>          // filenames actually parsed (scopes allowlist checks)
}

public enum TokenLoader {
    /// iOS mode choices for multi-mode collections (PLAN.md Q3: mobile uses Small at codegen).
    /// Every collection that has more than one mode MUST be pinned here so codegen knows which
    /// single mode iOS ships — an unpinned multi-mode collection fails fast in `selectedFiles`.
    static let modeForCollection: [String: String] = [
        "system": "ios",
        "screen-size": "small-(s)",
        "theme": "alfie-theme",
    ]
    static let documentationPrefix = "~~doc-"

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
        return LoadedTokens(map: map, primitiveValues: primitiveValues, loadedFiles: loaded)
    }

    /// Filenames to load: skip `.documentation`; pick the iOS mode for multi-mode collections;
    /// include single-mode collections and the typography styles.
    static func selectedFiles(manifestURL: URL) throws -> [String] {
        let name = manifestURL.lastPathComponent
        let data = try Data(contentsOf: manifestURL)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DesignTokenError.malformedToken(name: name, reason: "not an object")
        }
        var files: [String] = []
        if let collections = root["collections"] as? [String: Any] {
            for (collection, value) in collections {
                if collection == ".documentation" { continue }
                // A collection without a `modes` dictionary is contract drift — fail fast rather than
                // silently dropping its tokens from the generated set.
                guard let modes = (value as? [String: Any])?["modes"] as? [String: Any] else {
                    throw DesignTokenError.malformedToken(name: name, reason: "collection '\(collection)' has no 'modes' dictionary")
                }
                let chosen: [Any]
                if let mode = modeForCollection[collection] {
                    // A configured collection MUST expose its expected mode — falling back to an empty
                    // list would silently emit an incomplete token set.
                    guard let list = modes[mode] as? [Any] else {
                        throw DesignTokenError.malformedToken(name: name, reason: "collection '\(collection)' is missing expected mode '\(mode)'")
                    }
                    chosen = list
                } else if modes.count <= 1 {
                    // Single-mode collection: load its only mode.
                    chosen = modes.values.compactMap { $0 as? [Any] }.flatMap { $0 }
                } else {
                    // A newly multi-mode collection with no pin would otherwise load every mode's file
                    // — including ones pull-design-tokens.sh doesn't ship — and crash later with an
                    // opaque fileNotFound. Fail here with an actionable message instead.
                    let modeNames = modes.keys.sorted().joined(separator: ", ")
                    throw DesignTokenError.malformedToken(name: name, reason: "collection '\(collection)' has multiple modes [\(modeNames)] but no pinned mode — add one to TokenLoader.modeForCollection to select the iOS mode")
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
}
