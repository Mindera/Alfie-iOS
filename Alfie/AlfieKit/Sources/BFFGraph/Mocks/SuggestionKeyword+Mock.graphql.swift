// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class SuggestionKeyword: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.SuggestionKeyword
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SuggestionKeyword>>

  public struct MockFields {
    @Field<Int>("results") public var results
    @Field<String>("value") public var value
  }
}

public extension Mock where O == SuggestionKeyword {
  convenience init(
    results: Int? = nil,
    value: String? = nil
  ) {
    self.init()
    _setScalar(results, for: \.results)
    _setScalar(value, for: \.value)
  }
}
