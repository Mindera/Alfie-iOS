// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct CartLineOptionInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      name: String,
      value: String
    ) {
      __data = InputDict([
        "name": name,
        "value": value
      ])
    }

    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    public var value: String {
      get { __data["value"] }
      set { __data["value"] = newValue }
    }
  }

}