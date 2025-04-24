// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class Video: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Video
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Video>>

  public struct MockFields {
    @Field<String>("alt") public var alt
    @Field<GraphQLEnum<BFFGraphAPI.MediaContentType>>("mediaContentType") public var mediaContentType
    @Field<Image>("previewImage") public var previewImage
    @Field<[VideoSource]>("sources") public var sources
  }
}

public extension Mock where O == Video {
  convenience init(
    alt: String? = nil,
    mediaContentType: GraphQLEnum<BFFGraphAPI.MediaContentType>? = nil,
    previewImage: Mock<Image>? = nil,
    sources: [Mock<VideoSource>]? = nil
  ) {
    self.init()
    _setScalar(alt, for: \.alt)
    _setScalar(mediaContentType, for: \.mediaContentType)
    _setEntity(previewImage, for: \.previewImage)
    _setList(sources, for: \.sources)
  }
}
