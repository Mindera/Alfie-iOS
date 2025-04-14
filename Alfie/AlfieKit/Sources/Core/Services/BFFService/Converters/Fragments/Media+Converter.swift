import BFFGraphAPI
import Common
import Foundation
import Model

public extension BFFGraphAPI.MediaFragment {
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

extension BFFGraphAPI.ImageFragment {
    func convertToImage() -> MediaImage? {
        guard
            url.isNotBlank,
            let url = URL(string: url)
        else {
            return nil
        }

        return MediaImage(alt: alt, mediaContentType: .image, url: url)
    }
}

private extension BFFGraphAPI.MediaFragment.AsImage {
    func convertToImage() -> MediaImage? {
        fragments.imageFragment.convertToImage()
    }
}

private extension BFFGraphAPI.MediaFragment.AsVideo {
    func convertToVideo() -> MediaVideo? {
        let sources: [VideoSource] = sources.compactMap { source -> VideoSource? in
            guard
                source.url.isNotBlank,
                let url = URL(string: source.url)
            else {
                return nil
            }

            return VideoSource(format: VideoSource.VideoFormat(from: source), mimeType: source.mimeType, url: url)
        }
        let previewImage = previewImage?.fragments.imageFragment.convertToImage()
        return MediaVideo(alt: alt, mediaContentType: .video, previewImage: previewImage, sources: sources)
    }
}

private extension VideoSource.VideoFormat {
    init(from source: BFFGraphAPI.MediaFragment.AsVideo.Source) {
        // swiftlint:disable vertical_whitespace_between_cases
        self = switch source.format {
        case .mp4:
            .mp4
        case .webm:
            .webm
        case .case:
            .unknown
        case .unknown:
            .unknown
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}
