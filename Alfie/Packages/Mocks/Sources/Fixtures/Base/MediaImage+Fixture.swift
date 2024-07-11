import Foundation
import Models

extension MediaImage {
    public static func fixture(alt: String? = nil,
                               mediaContentType: MediaContentType = .image,
                               url: URL = URL(string: "https://www.alfieproj.com/images/assetimages/footer/alfie.png")!) -> MediaImage {
        .init(alt: alt,
              mediaContentType: mediaContentType,
              url: url)
    }
}
