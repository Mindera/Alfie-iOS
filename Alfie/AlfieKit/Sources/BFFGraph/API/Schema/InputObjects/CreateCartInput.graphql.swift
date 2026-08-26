// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct CreateCartInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      customerAccessToken: GraphQLNullable<String> = nil,
      lines: GraphQLNullable<[CartLineInput]> = nil
    ) {
      __data = InputDict([
        "customerAccessToken": customerAccessToken,
        "lines": lines
      ])
    }

    public var customerAccessToken: GraphQLNullable<String> {
      get { __data["customerAccessToken"] }
      set { __data["customerAccessToken"] = newValue }
    }

    public var lines: GraphQLNullable<[CartLineInput]> {
      get { __data["lines"] }
      set { __data["lines"] = newValue }
    }
  }

}