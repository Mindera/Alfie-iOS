// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraph

class OmniProduct: MockObject {
  static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.OmniProduct
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<OmniProduct>>

  struct MockFields {
    @Field<String>("brandName") public var brandName
    @Field<String>("defaultVariantId") public var defaultVariantId
    @Field<String>("descriptionHtml") public var descriptionHtml
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<Int>("inventoryTotal") public var inventoryTotal
    @Field<String>("name") public var name
    @Field<MoneyRange>("priceRange") public var priceRange
    @Field<Image>("primaryImage") public var primaryImage
    @Field<String>("productType") public var productType
    @Field<String>("slug") public var slug
    @Field<[ProductVariant?]>("variants") public var variants
  }
}

extension Mock where O == OmniProduct {
  convenience init(
    brandName: String? = nil,
    defaultVariantId: String? = nil,
    descriptionHtml: String? = nil,
    id: BFFGraphAPI.ID? = nil,
    inventoryTotal: Int? = nil,
    name: String? = nil,
    priceRange: Mock<MoneyRange>? = nil,
    primaryImage: Mock<Image>? = nil,
    productType: String? = nil,
    slug: String? = nil,
    variants: [Mock<ProductVariant>?]? = nil
  ) {
    self.init()
    _setScalar(brandName, for: \.brandName)
    _setScalar(defaultVariantId, for: \.defaultVariantId)
    _setScalar(descriptionHtml, for: \.descriptionHtml)
    _setScalar(id, for: \.id)
    _setScalar(inventoryTotal, for: \.inventoryTotal)
    _setScalar(name, for: \.name)
    _setEntity(priceRange, for: \.priceRange)
    _setEntity(primaryImage, for: \.primaryImage)
    _setScalar(productType, for: \.productType)
    _setScalar(slug, for: \.slug)
    _setList(variants, for: \.variants)
  }
}
