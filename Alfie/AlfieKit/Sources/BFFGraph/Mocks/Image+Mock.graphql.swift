// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class Image: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Image
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Image>>

  public struct MockFields {
    @Field<String>("alt") public var alt
    @Field<GraphQLEnum<BFFGraphAPI.MediaContentType>>("mediaContentType") public var mediaContentType
    @Field<BFFGraphAPI.URL>("url") public var url
  }
}

public extension Mock where O == Image {
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
