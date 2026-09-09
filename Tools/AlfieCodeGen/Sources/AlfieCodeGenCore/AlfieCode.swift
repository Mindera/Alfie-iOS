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

    /// The host the app already accepts in `LinkConfiguration`, so a scan needs no config change.
    public static let defaultBaseURL = URL(string: "https://localhost:4000")!

    // MARK: - Validity

    /// Why this code cannot be printed, in words a reader can act on — or `nil` when it is fine.
    ///
    /// A Handle has to survive into a URL path untouched: anything else is a typo, an
    /// already-encoded string, or a whole URL pasted in by mistake, and each of those prints a code
    /// that fails silently in the meeting room.
    public var problem: String? {
        if handle.isEmpty {
            return "there is no handle"
        }
        if let scalar = handle.unicodeScalars.first(where: { !Self.handleCharacters.contains($0) }) {
            return "it contains \"\(Character(scalar))\", which is not allowed in a handle"
        }
        if handle.hasPrefix("/") || handle.hasSuffix("/") {
            return "a handle does not start or end with \"/\""
        }
        if handle.contains("//") {
            return "it has an empty path segment (\"//\")"
        }
        if let sku, sku.isEmpty {
            return "there is a comma but no SKU after it"
        }
        return nil
    }

    // MARK: - Output

    /// The link encoded into the printed code: `<base>/product/<handle>[?sku=<sku>]`.
    ///
    /// The Handle goes in as path segments — a BigCommerce Handle legitimately contains `/` — while
    /// the SKU is percent-encoded, because it is a supplier's string and we do not control it.
    public func url(baseURL: URL) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw AlfieCodeError.invalidBaseURL(baseURL.absoluteString)
        }

        var path = components.path
        if path.hasSuffix("/") {
            path.removeLast()
        }
        components.path = path + "/product/" + handle

        if let sku {
            components.percentEncodedQuery = "sku=" + Self.percentEncoded(sku)
        }

        guard let url = components.url else {
            throw AlfieCodeError.invalidBaseURL(baseURL.absoluteString)
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
