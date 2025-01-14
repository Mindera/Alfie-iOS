// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphApi

public class Variant: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphApi.Objects.Variant
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Variant>>

  public struct MockFields {
    @Field<[KeyValuePair]>("attributes") public var attributes
    @Field<Colour>("colour") public var colour
    @Field<Price>("price") public var price
    @Field<Size>("size") public var size
    @Field<BFFGraphApi.ID>("sku") public var sku
    @Field<Int>("stock") public var stock
  }
}

public extension Mock where O == Variant {
  convenience init(
    attributes: [Mock<KeyValuePair>]? = nil,
    colour: Mock<Colour>? = nil,
    price: Mock<Price>? = nil,
    size: Mock<Size>? = nil,
    sku: BFFGraphApi.ID? = nil,
    stock: Int? = nil
  ) {
    self.init()
    _setList(attributes, for: \.attributes)
    _setEntity(colour, for: \.colour)
    _setEntity(price, for: \.price)
    _setEntity(size, for: \.size)
    _setScalar(sku, for: \.sku)
    _setScalar(stock, for: \.stock)
  }
}
