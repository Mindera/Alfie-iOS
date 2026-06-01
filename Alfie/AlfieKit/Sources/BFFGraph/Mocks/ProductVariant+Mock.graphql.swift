// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class ProductVariant: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.ProductVariant
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<ProductVariant>>

  struct MockFields {
    @Field<Money>("compareAtPrice") public var compareAtPrice
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<Inventory>("inventory") public var inventory
    @Field<[Image?]>("media") public var media
    @Field<[VariantOption]>("optionValues") public var optionValues
    @Field<Money>("price") public var price
    @Field<String>("sku") public var sku
  }
}

extension Mock where O == ProductVariant {
  convenience init(
    compareAtPrice: Mock<Money>? = nil,
    id: BFFGraphAPI.ID? = nil,
    inventory: Mock<Inventory>? = nil,
    media: [Mock<Image>?]? = nil,
    optionValues: [Mock<VariantOption>]? = nil,
    price: Mock<Money>? = nil,
    sku: String? = nil
  ) {
    self.init()
    _setEntity(compareAtPrice, for: \.compareAtPrice)
    _setScalar(id, for: \.id)
    _setEntity(inventory, for: \.inventory)
    _setList(media, for: \.media)
    _setList(optionValues, for: \.optionValues)
    _setEntity(price, for: \.price)
    _setScalar(sku, for: \.sku)
  }
}
