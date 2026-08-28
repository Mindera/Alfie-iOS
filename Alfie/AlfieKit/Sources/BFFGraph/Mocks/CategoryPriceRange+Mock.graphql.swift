// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class CategoryPriceRange: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.CategoryPriceRange
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<CategoryPriceRange>>

  struct MockFields {
    @Field<Money>("maxVariantPrice") public var maxVariantPrice
    @Field<Money>("minVariantPrice") public var minVariantPrice
  }
}

extension Mock where O == CategoryPriceRange {
  convenience init(
    maxVariantPrice: Mock<Money>? = nil,
    minVariantPrice: Mock<Money>? = nil
  ) {
    self.init()
    _setEntity(maxVariantPrice, for: \.maxVariantPrice)
    _setEntity(minVariantPrice, for: \.minVariantPrice)
  }
}
