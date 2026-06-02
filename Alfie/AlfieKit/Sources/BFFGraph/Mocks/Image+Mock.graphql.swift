// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Image: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Image
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Image>>

  struct MockFields {
    @Field<String>("altText") public var altText
    @Field<String>("url") public var url
  }
}

extension Mock where O == Image {
  convenience init(
    altText: String? = nil,
    url: String? = nil
  ) {
    self.init()
    _setScalar(altText, for: \.altText)
    _setScalar(url, for: \.url)
  }
}
