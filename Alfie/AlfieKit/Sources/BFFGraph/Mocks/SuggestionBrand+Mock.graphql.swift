// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class SuggestionBrand: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.SuggestionBrand
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SuggestionBrand>>

  public struct MockFields {
    @Field<Int>("results") public var results
    @Field<String>("slug") public var slug
    @Field<String>("value") public var value
  }
}

public extension Mock where O == SuggestionBrand {
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
