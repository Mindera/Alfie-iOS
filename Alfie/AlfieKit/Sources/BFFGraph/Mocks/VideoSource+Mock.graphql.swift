// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class VideoSource: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.VideoSource
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<VideoSource>>

  struct MockFields {
    @Field<GraphQLEnum<BFFGraphApi.VideoFormat>>("format") public var format
    @Field<String>("mimeType") public var mimeType
    @Field<BFFGraphApi.URL>("url") public var url
  }
}

extension Mock where O == VideoSource {
  convenience init(
    format: GraphQLEnum<BFFGraphApi.VideoFormat>? = nil,
    mimeType: String? = nil,
    url: BFFGraphApi.URL? = nil
  ) {
    self.init()
    _setScalar(format, for: \.format)
    _setScalar(mimeType, for: \.mimeType)
    _setScalar(url, for: \.url)
  }
}
