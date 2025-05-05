import ApolloTestSupport
import BFFGraphAPI
import BFFGraphMocks

extension Mock<Image> {
    static func mock(
        alt: String? = nil,
        url: String = "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
    ) -> Mock<Image> {
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
    static func mock(
        format: BFFGraphAPI.VideoFormat = .mp4,
        mimeType: String = "video/mp4",
        url: String = "https://videos.pexels.com/video-files/3912502/3912502-uhd_2560_1440_25fps.mp4"
    ) -> Mock<VideoSource> {
        Mock<VideoSource>(format: .some(.case(format)),
                          mimeType: mimeType,
                          url: url)
    }
}
