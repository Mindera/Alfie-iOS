// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct FacetFilterInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      facetId: String,
      value: String
    ) {
      __data = InputDict([
        "facetId": facetId,
        "value": value
      ])
    }

    public var facetId: String {
      get { __data["facetId"] }
      set { __data["facetId"] = newValue }
    }

    public var value: String {
      get { __data["value"] }
      set { __data["value"] = newValue }
    }
  }

}