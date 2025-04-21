// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Video: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Video
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Video>>

  struct MockFields {
    @Field<String>("alt") public var alt
    @Field<GraphQLEnum<BFFGraphApi.MediaContentType>>("mediaContentType") public var mediaContentType
    @Field<Image>("previewImage") public var previewImage
    @Field<[VideoSource]>("sources") public var sources
  }
}

extension Mock where O == Video {
  convenience init(
    alt: String? = nil,
    mediaContentType: GraphQLEnum<BFFGraphApi.MediaContentType>? = nil,
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
