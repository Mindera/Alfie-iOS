import Foundation

/// One printable Alfie code: a Product Handle, and optionally the SKU of the Variant the tag is
/// attached to. The link format is fixed by the spec — see
/// `Docs/adr/0001-print-our-own-alfie-code.md`.
public struct AlfieCode: Equatable {
    public let handle: String
    public let sku: String?

    public init(handle: String, sku: String? = nil) {
        self.handle = handle
        self.sku = sku
    }

    // MARK: - Validity

    /// Why a Handle cannot be printed. Typed rather than stringly, so a caller can react to the
    /// rule that fired and a test can name it.
    public enum Problem: Equatable, CustomStringConvertible {
        case noHandle
        case disallowedCharacter(Character)
        case slashAtEdge
        case emptyPathSegment

        public var description: String {
            switch self {
            case .noHandle:
                return "there is no handle"
            case .disallowedCharacter(let character):
                return "it contains \"\(character)\", which is not allowed in a handle"
            case .slashAtEdge:
                return "a handle does not start or end with \"/\""
            case .emptyPathSegment:
                return "it has an empty path segment (\"//\")"
            }
        }
    }

    /// Why this code cannot be printed, in words a reader can act on — or `nil` when it is fine.
    ///
    /// A Handle has to survive into a URL path untouched: anything else is a typo, an
    /// already-encoded string, or a whole URL pasted in by mistake, and each of those prints a code
    /// that fails silently in the meeting room.
    public var problem: Problem? {
        if handle.isEmpty {
            return .noHandle
        }
        if let scalar = handle.unicodeScalars.first(where: { !Self.handleCharacters.contains($0) }) {
            return .disallowedCharacter(Character(scalar))
        }
        if handle.hasPrefix("/") || handle.hasSuffix("/") {
            return .slashAtEdge
        }
        if handle.contains("//") {
            return .emptyPathSegment
        }
        return nil
    }

    // MARK: - Output

    /// The link encoded into the printed code: `https://localhost:4000/product/<handle>[?sku=<sku>]`.
    ///
    /// The host is not configurable, and deliberately so: it is the one `LinkConfiguration` already
    /// accepts, so a scan needs no app config change — and a code carrying any other host is a code
    /// the app refuses to route. It is assembled from parts rather than parsed from a literal, so
    /// there is no string here to force-unwrap.
    ///
    /// The Handle goes in as path segments — a BigCommerce Handle legitimately contains `/` — while
    /// the SKU is percent-encoded, because it is a supplier's string and we do not control it.
    public func url() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "localhost"
        components.port = 4000
        components.path = "/product/" + handle

        if let sku {
            components.percentEncodedQuery = "sku=" + Self.percentEncoded(sku)
        }

        guard let url = components.url else {
            throw AlfieCodeError.invalidLink(handle: handle)
        }
        return url
    }

    /// The image file this code is written to. Distinct per entry, and safe on any filesystem —
    /// a Handle's `/` would otherwise read as a directory.
    public var fileName: String {
        var name = Self.slugified(handle)
        if let sku {
            name += "--sku-" + Self.slugified(sku)
        }
        return name + ".png"
    }

    /// A caption for the printed sheet, so a human can tell one tag from another.
    public var caption: String {
        guard let sku else { return handle }
        return "\(handle) · \(sku)"
    }

    // MARK: - Alphabets

    private static let asciiAlphanumerics =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    /// The characters a Handle may use unescaped in a URL path.
    static let handleCharacters = CharacterSet(charactersIn: asciiAlphanumerics + "-._~/")
    /// What survives a query value without percent-encoding.
    private static let unreservedQueryCharacters = CharacterSet(charactersIn: asciiAlphanumerics + "-._~")
    /// What is safe in a file name on any filesystem we print from.
    private static let fileNameSafeCharacters = CharacterSet(charactersIn: asciiAlphanumerics + "-_.")

    private static func percentEncoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreservedQueryCharacters) ?? value
    }

    private static func slugified(_ value: String) -> String {
        String(value.unicodeScalars.map { fileNameSafeCharacters.contains($0) ? Character($0) : "-" })
    }
}
