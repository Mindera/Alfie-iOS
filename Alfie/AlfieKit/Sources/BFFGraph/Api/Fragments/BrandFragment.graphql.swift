// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct BrandFragment: BFFGraphApi.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment BrandFragment on Brand { __typename id name slug }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Brand }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", BFFGraphApi.ID.self),
    .field("name", String.self),
    .field("slug", String.self),
  ] }

  /// The ID for the brand
  public var id: BFFGraphApi.ID { __data["id"] }
  /// The display name of the brand
  public var name: String { __data["name"] }
  /// A slugified name for URL usage
  public var slug: String { __data["slug"] }
}