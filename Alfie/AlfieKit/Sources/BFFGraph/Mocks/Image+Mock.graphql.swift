// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Image: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Image
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Image>>

  struct MockFields {
    @Field<String>("alt") public var alt
    @Field<GraphQLEnum<BFFGraphAPI.MediaContentType>>("mediaContentType") public var mediaContentType
    @Field<BFFGraphAPI.URL>("url") public var url
  }
}

extension Mock where O == Image {
  convenience init(
    alt: String? = nil,
    mediaContentType: GraphQLEnum<BFFGraphAPI.MediaContentType>? = nil,
    url: BFFGraphAPI.URL? = nil
  ) {
    self.init()
    _setScalar(alt, for: \.alt)
    _setScalar(mediaContentType, for: \.mediaContentType)
    _setScalar(url, for: \.url)
  }
}
