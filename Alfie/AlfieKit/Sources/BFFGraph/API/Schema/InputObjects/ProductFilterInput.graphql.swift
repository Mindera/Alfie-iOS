// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI {
  struct ProductFilterInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      brandNames: GraphQLNullable<[String]> = nil,
      inventory: GraphQLNullable<Bool> = nil,
      maxPrice: GraphQLNullable<Double> = nil,
      metafields: GraphQLNullable<[MetafieldFilterInput]> = nil,
      minPrice: GraphQLNullable<Double> = nil,
      productTypes: GraphQLNullable<[String]> = nil
    ) {
      __data = InputDict([
        "brandNames": brandNames,
        "inventory": inventory,
        "maxPrice": maxPrice,
        "metafields": metafields,
        "minPrice": minPrice,
        "productTypes": productTypes
      ])
    }

    public var brandNames: GraphQLNullable<[String]> {
      get { __data["brandNames"] }
      set { __data["brandNames"] = newValue }
    }

    public var inventory: GraphQLNullable<Bool> {
      get { __data["inventory"] }
      set { __data["inventory"] = newValue }
    }

    public var maxPrice: GraphQLNullable<Double> {
      get { __data["maxPrice"] }
      set { __data["maxPrice"] = newValue }
    }

    public var metafields: GraphQLNullable<[MetafieldFilterInput]> {
      get { __data["metafields"] }
      set { __data["metafields"] = newValue }
    }

    public var minPrice: GraphQLNullable<Double> {
      get { __data["minPrice"] }
      set { __data["minPrice"] = newValue }
    }

    public var productTypes: GraphQLNullable<[String]> {
      get { __data["productTypes"] }
      set { __data["productTypes"] = newValue }
    }
  }

}