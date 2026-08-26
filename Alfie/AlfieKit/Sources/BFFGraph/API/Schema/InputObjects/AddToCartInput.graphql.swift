// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct AddToCartInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      cartId: ID,
      lines: [CartLineInput]
    ) {
      __data = InputDict([
        "cartId": cartId,
        "lines": lines
      ])
    }

    public var cartId: ID {
      get { __data["cartId"] }
      set { __data["cartId"] = newValue }
    }

    public var lines: [CartLineInput] {
      get { __data["lines"] }
      set { __data["lines"] = newValue }
    }
  }

}