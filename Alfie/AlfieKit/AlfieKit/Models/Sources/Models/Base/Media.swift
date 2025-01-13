import Foundation

public enum Media {
    case image(MediaImage)
    case video(MediaVideo)

    public var asImage: MediaImage? {
        guard case .image(let image) = self else {
            return nil
        }
        return image
    }

    public var asVideo: MediaVideo? {
        guard case .video(let video) = self else {
            return nil
        }
        return video
    }
}

public enum MediaContentType: String {
    case image = "IMAGE"
    case video = "VIDEO"
}
