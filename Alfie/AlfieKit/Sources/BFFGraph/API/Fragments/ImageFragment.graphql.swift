// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct ImageFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ImageFragment on Image { __typename url altText }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("url", String.self),
      .field("altText", String?.self),
    ] }

    public var url: String { __data["url"] }
    public var altText: String? { __data["altText"] }
  }

}