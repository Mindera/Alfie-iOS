// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class CartItem: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.CartItem
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<CartItem>>

  struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<Image>("image") public var image
    @Field<Money>("lineTotal") public var lineTotal
    @Field<String>("name") public var name
    @Field<Money>("price") public var price
    @Field<String>("productId") public var productId
    @Field<Int>("quantity") public var quantity
    @Field<String>("sku") public var sku
    @Field<String>("variantId") public var variantId
  }
}

extension Mock where O == CartItem {
  convenience init(
    id: BFFGraphAPI.ID? = nil,
    image: Mock<Image>? = nil,
    lineTotal: Mock<Money>? = nil,
    name: String? = nil,
    price: Mock<Money>? = nil,
    productId: String? = nil,
    quantity: Int? = nil,
    sku: String? = nil,
    variantId: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setEntity(image, for: \.image)
    _setEntity(lineTotal, for: \.lineTotal)
    _setScalar(name, for: \.name)
    _setEntity(price, for: \.price)
    _setScalar(productId, for: \.productId)
    _setScalar(quantity, for: \.quantity)
    _setScalar(sku, for: \.sku)
    _setScalar(variantId, for: \.variantId)
  }
}
