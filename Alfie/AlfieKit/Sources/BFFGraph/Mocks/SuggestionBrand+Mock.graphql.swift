// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class SuggestionBrand: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.SuggestionBrand
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<SuggestionBrand>>

  struct MockFields {
    @Field<Int>("results") public var results
    @Field<String>("slug") public var slug
    @Field<String>("value") public var value
  }
}

extension Mock where O == SuggestionBrand {
  convenience init(
    results: Int? = nil,
    slug: String? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(results, for: \.results)
    _setScalar(slug, for: \.slug)
    _setScalar(value, for: \.value)
  }
}
