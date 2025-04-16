// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphApi.Unions {
  /// Represents a media resource.
  static let Media = Union(
    name: "Media",
    possibleTypes: [
      BFFGraphApi.Objects.Image.self,
      BFFGraphApi.Objects.Video.self
    ]
  )
}