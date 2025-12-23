import Foundation

public struct MediaImage: Hashable {
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
}
