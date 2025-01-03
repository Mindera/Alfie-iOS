import Foundation
import Models

extension MediaVideo {
    public static func fixture(alt: String? = nil,
                               mediaContentType: MediaContentType = .video,
                               previewImage: MediaImage? = nil,
                               sources: [VideoSource] = [.fixture()]) -> MediaVideo {
        .init(alt: alt,
              mediaContentType: mediaContentType,
              previewImage: previewImage,
              sources: sources)
    }
}

extension VideoSource {
    public static func fixture(format: VideoFormat = .mp4,
                               mimeType: String = "video/mp4",
                               url: URL = URL(string: "https://videos.pexels.com/video-files/3912502/3912502-uhd_2560_1440_25fps.mp4")!) -> VideoSource {
        .init(format: format,
              mimeType: mimeType,
              url: url)
    }
}
