import ApolloTestSupport
@testable import BFFGraph
import XCTest

final class MediaConverterTests: XCTestCase {

    // MARK: Media Image

    func test_image_valid_image() {
        let image: Mock<Image> = .mock(
            alt: "Accessibility description",
            url: "https://www.alfieproj.com/images/assetimages/footer/alfie.png"
        )
        let mockMedia = BFFGraphAPI.MediaFragment.from(image)

        let media = mockMedia.convertToMedia()

        guard let mediaImage = media?.asImage else {
            XCTFail("MediaConverter failed for image")
            return
        }

        XCTAssertEqual(mediaImage.alt, "Accessibility description")
        XCTAssertEqual(mediaImage.mediaContentType, .image)
        XCTAssertEqual(
            mediaImage.url,
            URL(string: "https://www.alfieproj.com/images/assetimages/footer/alfie.png")
        )
    }

    func test_image_with_unknown_content_type_fallback_to_image_media() {
        let image = Mock<Image>(alt: nil,
                                mediaContentType: .unknown("gif"),
                                url: "url")
        let mockMedia = BFFGraphAPI.MediaFragment.from(image)

        let media = mockMedia.convertToMedia()

        XCTAssertEqual(media?.asImage?.mediaContentType, .image)
    }

    func test_image_missing_url_no_image() {
        let image: Mock<Image> = .mock(url: "")
        let mockMedia = BFFGraphAPI.MediaFragment.from(image)

        let media = mockMedia.convertToMedia()

        XCTAssertNil(media)
    }

    // MARK: Media Video

    func test_video_valid_video() {
        let video: Mock<Video> = .mock(
            alt: "Accessibility description",
            previewImage: .mock(),
            sources: [
                .mock(
                    format: .mp4,
                    mimeType: "video/mp4",
                    url: "https://www.alfieproj.com/images/assetvideos/demo-video.mp4"
                ),
            ]
        )
        let mockMedia = BFFGraphAPI.MediaFragment.from(video)

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
            URL(string: "https://www.alfieproj.com/images/assetvideos/demo-video.mp4")
        )
    }

    func test_video_missing_url_video_with_only_preview_image() {
        let video: Mock<Video> = .mock(sources: [.mock(url: "")])
        let mockMedia = BFFGraphAPI.MediaFragment.from(video)

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
            url: "https://www.alfieproj.com/images/assetvideos/demo-video.mov"
        )
        let video: Mock<Video> = .mock(alt: "Accessibility description",
                                       previewImage: .mock(),
                                       sources: [source])
        let mockMedia = BFFGraphAPI.MediaFragment.from(video)

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
