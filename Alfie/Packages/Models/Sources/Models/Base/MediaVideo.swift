import Foundation

public struct MediaVideo {
    /// A description of the contents of the video for accessibility purposes.
    public let alt: String?
    /// The media content type.
    public let mediaContentType: MediaContentType
    /// A preview image for the video.
    public let previewImage: MediaImage?
    /// The sources for the video.
    public let sources: [VideoSource]

    public init(alt: String?, mediaContentType: MediaContentType, previewImage: MediaImage?, sources: [VideoSource]) {
        self.alt = alt
        self.mediaContentType = mediaContentType
        self.previewImage = previewImage
        self.sources = sources
    }
}

public struct VideoSource {
    public enum VideoFormat: String {
        case mp4 = "MP4"
        case webm = "WEBM"
        case unknown
    }

    /// The format of the video source."
    public let format: VideoFormat
    /// The video MIME type."
    public let mimeType: String
    /// The URL of the video."
    public let url: URL

    public init(format: VideoFormat, mimeType: String, url: URL) {
        self.format = format
        self.mimeType = mimeType
        self.url = url
    }
}
