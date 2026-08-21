// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class Query: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Query
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Query>>

  struct MockFields {
    @Field<CategoryPriceRange>("categoryPriceRange") public var categoryPriceRange
    @Field<Menu>("menu") public var menu
    @Field<OmniProduct>("productDetails") public var productDetails
    @Field<ProductListResponse>("productList") public var productList
    @Field<ProductListResponse>("searchProducts") public var searchProducts
  }
}

extension Mock where O == Query {
  convenience init(
    categoryPriceRange: Mock<CategoryPriceRange>? = nil,
    menu: Mock<Menu>? = nil,
    productDetails: Mock<OmniProduct>? = nil,
    productList: Mock<ProductListResponse>? = nil,
    searchProducts: Mock<ProductListResponse>? = nil
  ) {
    self.init()
    _setEntity(categoryPriceRange, for: \.categoryPriceRange)
    _setEntity(menu, for: \.menu)
    _setEntity(productDetails, for: \.productDetails)
    _setEntity(productList, for: \.productList)
    _setEntity(searchProducts, for: \.searchProducts)
  }
}
