// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct CartLineInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      options: GraphQLNullable<[CartLineOptionInput]> = nil,
      productId: GraphQLNullable<ID> = nil,
      quantity: Int? = nil,
      variantId: ID
    ) {
      __data = InputDict([
        "options": options,
        "productId": productId,
        "quantity": quantity,
        "variantId": variantId
      ])
    }

    public var options: GraphQLNullable<[CartLineOptionInput]> {
      get { __data["options"] }
      set { __data["options"] = newValue }
    }

    public var productId: GraphQLNullable<ID> {
      get { __data["productId"] }
      set { __data["productId"] = newValue }
    }

    public var quantity: Int? {
      get { __data["quantity"] }
      set { __data["quantity"] = newValue }
    }

    public var variantId: ID {
      get { __data["variantId"] }
      set { __data["variantId"] = newValue }
    }
  }

}