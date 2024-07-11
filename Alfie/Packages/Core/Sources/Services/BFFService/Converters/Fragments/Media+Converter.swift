import BFFGraphApi
import Common
import Foundation
import Models

public extension MediaFragment {
    func convertToMedia() -> Media? {
        if let mediaVideo = self.asVideo?.convertToVideo() {
            return .video(mediaVideo)
        } else if let mediaImage = self.asImage?.convertToImage() {
            return .image(mediaImage)
        } else {
            return nil
        }
    }
}

extension ImageFragment {
    func convertToImage() -> MediaImage? {
        guard url.isNotBlank, let url = URL(string: url) else {
            return nil
        }

        return MediaImage(alt: alt,
                          mediaContentType: .image,
                          url: url)
    }
}

private extension MediaFragment.AsImage {
    func convertToImage() -> MediaImage? {
        fragments.imageFragment.convertToImage()
    }
}

private extension MediaFragment.AsVideo {
    func convertToVideo() -> MediaVideo? {
        let sources: [VideoSource] = sources.compactMap { source -> VideoSource? in
            guard source.url.isNotBlank, let url = URL(string: source.url) else {
                return nil
            }

            return VideoSource(format: VideoSource.VideoFormat(from: source),
                               mimeType: source.mimeType,
                               url: url)
        }
        let previewImage = previewImage?.fragments.imageFragment.convertToImage()
        return MediaVideo(alt: alt,
                          mediaContentType: .video,
                          previewImage: previewImage,
                          sources: sources)
    }
}

private extension VideoSource.VideoFormat {
    init(from source: MediaFragment.AsVideo.Source) {
        self = switch source.format {
                case .mp4: .mp4
                case .webm: .webm
                case .case: .unknown
                case .unknown: .unknown
        }
    }
}
