// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphApi.Objects {
  /// App often display a price range or a 'from'.
  /// If this data is present in the product and no variant is selected, display the range.
  /// If high is null, display as 'From ${low}', otherwise '${low} to ${high}'
  static let PriceRange = ApolloAPI.Object(
    typename: "PriceRange",
    implementedInterfaces: [],
    keyFields: nil
  )
}