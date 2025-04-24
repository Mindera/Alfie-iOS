// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension BFFGraphAPI.Unions {
  /// Represents a media resource.
  static let Media = Union(
    name: "Media",
    possibleTypes: [
      BFFGraphAPI.Objects.Image.self,
      BFFGraphAPI.Objects.Video.self
    ]
  )
}