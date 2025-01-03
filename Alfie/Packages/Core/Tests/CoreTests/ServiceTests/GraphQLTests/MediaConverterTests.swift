import ApolloTestSupport
import BFFGraphApi
import BFFGraphMocks
import XCTest

final class MediaConverterTests: XCTestCase {

    // MARK: Media Image

    func test_image_valid_image() {
        let image: Mock<Image> = .mock(
            alt: "Accessibility description",
            url: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
        )
        let mockMedia = MediaFragment.from(image)

        let media = mockMedia.convertToMedia()

        guard let mediaImage = media?.asImage else {
            XCTFail("MediaConverter failed for image")
            return
        }

        XCTAssertEqual(mediaImage.alt, "Accessibility description")
        XCTAssertEqual(mediaImage.mediaContentType, .image)
        XCTAssertEqual(
            mediaImage.url,
            URL(string: "https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
        )
    }

    func test_image_with_unknown_content_type_fallback_to_image_media() {
        let image = Mock<Image>(alt: nil,
                                mediaContentType: .unknown("gif"),
                                url: "url")
        let mockMedia = MediaFragment.from(image)

        let media = mockMedia.convertToMedia()

        XCTAssertEqual(media?.asImage?.mediaContentType, .image)
    }

    func test_image_missing_url_no_image() {
        let image: Mock<Image> = .mock(url: "")
        let mockMedia = MediaFragment.from(image)

        let media = mockMedia.convertToMedia()

        XCTAssertNil(media)
    }

    // MARK: Media Video

    func test_video_valid_video() {
        let video: Mock<Video> = .mock(
            alt: "Accessibility description",
            previewImage: .mock(),
            sources: [
                .mock(format: .mp4,
                      mimeType: "video/mp4",
                      url: "https://videos.pexels.com/video-files/3912502/3912502-uhd_2560_1440_25fps.mp4"),
            ]
        )
        let mockMedia = MediaFragment.from(video)

        let media = mockMedia.convertToMedia()

        guard let mediaVideo = media?.asVideo,
              let source = mediaVideo.sources.first
        else {
            XCTFail("MediaConverter failed for video")
            return
        }

        XCTAssertEqual(mediaVideo.alt, "Accessibility description")
        XCTAssertEqual(mediaVideo.mediaContentType, .video)
        XCTAssertNotNil(mediaVideo.previewImage)
        XCTAssertEqual(mediaVideo.sources.count, 1)
        XCTAssertEqual(source.format, .mp4)
        XCTAssertEqual(source.mimeType, "video/mp4")
        XCTAssertEqual(
            source.url,
            URL(string: "https://videos.pexels.com/video-files/3912502/3912502-uhd_2560_1440_25fps.mp4")
        )
    }

    func test_video_missing_url_video_with_only_preview_image() {
        let video: Mock<Video> = .mock(sources: [.mock(url: "")])
        let mockMedia = MediaFragment.from(video)

        let media = mockMedia.convertToMedia()

        guard let mediaVideo = media?.asVideo else {
            XCTFail("MediaConverter failed for video")
            return
        }
        XCTAssertTrue(mediaVideo.sources.isEmpty)
        XCTAssertNotNil(mediaVideo.previewImage)
    }

    func test_video_unsupported_video_format_video_with_unknown_format() {
        let source = Mock<VideoSource>(
            format: .unknown("mov"),
            mimeType: "video/mov",
            url: "https://videos.pexels.com/video-files/6960047/6960047-hd_1920_1080_30fps.mov"
        )
        let video: Mock<Video> = .mock(alt: "Accessibility description",
                                       previewImage: .mock(),
                                       sources: [source])
        let mockMedia = MediaFragment.from(video)

        let media = mockMedia.convertToMedia()

        guard let mediaVideo = media?.asVideo else {
            XCTFail("MediaConverter failed for video")
            return
        }

        XCTAssertEqual(mediaVideo.mediaContentType, .video)
        XCTAssertEqual(mediaVideo.sources.count, 1)
        XCTAssertEqual(mediaVideo.sources.first?.format, .unknown)
    }
}
