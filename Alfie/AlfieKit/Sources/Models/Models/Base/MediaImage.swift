import Foundation

public struct MediaImage: Equatable, Hashable {
    /// A description of the contents of the image for accessibility purposes.
    public let alt: String?
    /// The media content type.
    public let mediaContentType: MediaContentType
    /// The location of the image as a URL.
    public let url: URL

    public init(alt: String?, mediaContentType: MediaContentType, url: URL) {
        self.alt = alt
        self.mediaContentType = mediaContentType
        self.url = url
    }

    public static func == (lhs: MediaImage, rhs: MediaImage) -> Bool {
        lhs.alt == rhs.alt
        && lhs.mediaContentType == rhs.mediaContentType
        && lhs.url == rhs.url
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(alt)
        hasher.combine(mediaContentType)
        hasher.combine(url)
    }
}
