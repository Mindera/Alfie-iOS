import ApolloTestSupport
import BFFGraphApi
import BFFGraphMocks

extension Mock<Image> {
    static func mock(alt: String? = nil,
                     url: String = "https://www.alfieproj.com/images/assetimages/footer/alfie.png") -> Mock<Image> {
        Mock<Image>(alt: alt,
                    mediaContentType: .some(.case(.image)),
                    url: url)
    }
}

extension Mock<Video> {
    static func mock(alt: String? = nil,
                     previewImage: Mock<Image>? = .mock(),
                     sources: [Mock<VideoSource>]? = [.mock()]) -> Mock<Video> {
        Mock<Video>(alt: alt,
                    mediaContentType: .some(.case(.video)),
                    previewImage: previewImage,
                    sources: sources)
    }
}

extension Mock<VideoSource> {
    static func mock(format: VideoFormat = .mp4,
                     mimeType: String = "video/mp4",
                     url: String = "https://www.alfieproj.com/video/assetvideos/alfie.mp4") -> Mock<VideoSource> {
        Mock<VideoSource>(format: .some(.case(format)),
                          mimeType: mimeType,
                          url: url)
    }
}
