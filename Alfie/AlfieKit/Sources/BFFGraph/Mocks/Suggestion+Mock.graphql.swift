// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class Suggestion: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Suggestion
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Suggestion>>

  public struct MockFields {
    @Field<[SuggestionBrand]>("brands") public var brands
    @Field<[SuggestionKeyword]>("keywords") public var keywords
    @Field<[SuggestionProduct]>("products") public var products
  }
}

public extension Mock where O == Suggestion {
  convenience init(
    brands: [Mock<SuggestionBrand>]? = nil,
    keywords: [Mock<SuggestionKeyword>]? = nil,
    products: [Mock<SuggestionProduct>]? = nil
  ) {
    self.init()
    _setList(brands, for: \.brands)
    _setList(keywords, for: \.keywords)
    _setList(products, for: \.products)
  }
}
