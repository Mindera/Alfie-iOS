import Foundation

/// Everything that can go wrong preparing a print run. Each case carries enough context to fix the
/// input file without reading the source: the offending line, its number, and what was expected.
public enum AlfieCodeError: Error, Equatable, CustomStringConvertible {
    /// The list parsed, but held no handles at all.
    case emptyList
    /// A line could not be read as `handle` or `handle, sku`.
    case malformedLine(number: Int, line: String, reason: String)
    /// Two entries would produce the same image file, so one would silently overwrite the other.
    case duplicateEntry(fileName: String)
    /// The input file could not be read as UTF-8 text.
    case unreadableInput(path: String)
    /// The output directory could not be created or written to.
    case unwritableOutput(path: String, reason: String)
    /// CoreImage declined to encode the link — in practice, a payload too long for a QR code.
    case renderFailed(link: String)
    /// No URL could be assembled for this Handle, so there is nothing to encode.
    case invalidLink(handle: String)

    public var description: String {
        switch self {
        case .emptyList:
            return "The list has no handles in it. Put one product handle per line."
        case .malformedLine(let number, let line, let reason):
            return "Line \(number) (\"\(line)\") is not a handle: \(reason). "
                + "Expected `handle` or `handle, sku`."
        case .duplicateEntry(let fileName):
            return "Two entries both produce \(fileName). Remove the duplicate, or give them "
                + "different SKUs."
        case .unreadableInput(let path):
            return "Could not read a handle list at \(path)."
        case .unwritableOutput(let path, let reason):
            return "Could not write to \(path): \(reason)."
        case .renderFailed(let link):
            return "Could not encode \(link) as a QR code — the link is probably too long."
        case .invalidLink(let handle):
            return "No product link could be built for \"\(handle)\"."
        }
    }
}
