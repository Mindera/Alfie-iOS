// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct UpdateCartLineInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      id: ID,
      productId: GraphQLNullable<ID> = nil,
      quantity: Int,
      variantId: GraphQLNullable<ID> = nil
    ) {
      __data = InputDict([
        "id": id,
        "productId": productId,
        "quantity": quantity,
        "variantId": variantId
      ])
    }

    public var id: ID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }

    /// Required by BigCommerce; ignored by Shopify.
    public var productId: GraphQLNullable<ID> {
      get { __data["productId"] }
      set { __data["productId"] = newValue }
    }

    public var quantity: Int {
      get { __data["quantity"] }
      set { __data["quantity"] = newValue }
    }

    /// Required by BigCommerce; ignored by Shopify.
    public var variantId: GraphQLNullable<ID> {
      get { __data["variantId"] }
      set { __data["variantId"] = newValue }
    }
  }

}