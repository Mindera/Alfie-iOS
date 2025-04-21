// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class SuggestionKeyword: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.SuggestionKeyword
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<SuggestionKeyword>>

  struct MockFields {
    @Field<Int>("results") public var results
    @Field<String>("value") public var value
  }
}

extension Mock where O == SuggestionKeyword {
  convenience init(
    results: Int? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(results, for: \.results)
    _setScalar(value, for: \.value)
  }
}
