// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class ProductListing: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.ProductListing
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<ProductListing>>

  struct MockFields {
    @Field<Pagination>("pagination") public var pagination
    @Field<[Product]>("products") public var products
    @Field<String>("title") public var title
  }
}

extension Mock where O == ProductListing {
  convenience init(
    pagination: Mock<Pagination>? = nil,
    products: [Mock<Product>]? = nil,
    title: String? = nil
  ) {
    self.init()
    _setEntity(pagination, for: \.pagination)
    _setList(products, for: \.products)
    _setScalar(title, for: \.title)
  }
}
