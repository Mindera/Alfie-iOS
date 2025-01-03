import Foundation
import Models

extension MediaImage {
    public static func fixture(alt: String? = nil,
                               mediaContentType: MediaContentType = .image,
                               url: URL = URL(string: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1)")!) -> MediaImage {
        .init(alt: alt,
              mediaContentType: mediaContentType,
              url: url)
    }
}
