// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct ImageFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ImageFragment on Image { __typename alt mediaContentType url }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("alt", String?.self),
      .field("mediaContentType", GraphQLEnum<BFFGraphAPI.MediaContentType>.self),
      .field("url", BFFGraphAPI.URL.self),
    ] }

    /// A description of the contents of the image for accessibility purposes.
    public var alt: String? { __data["alt"] }
    /// The media content type.
    public var mediaContentType: GraphQLEnum<BFFGraphAPI.MediaContentType> { __data["mediaContentType"] }
    /// The location of the image as a URL.
    ///
    /// If no transform options are specified, then the original image will be preserved.
    ///
    /// All transformation options are considered "best-effort". Any transformation that the original image type doesn't support will be ignored.
    ///
    /// If you need multiple variations of the same image, then you can use [GraphQL aliases](https://graphql.org/learn/queries/#aliases).
    public var url: BFFGraphAPI.URL { __data["url"] }
  }

}