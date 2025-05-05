// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct ColourFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ColourFragment on Colour { __typename id name swatch { __typename ...ImageFragment } media { __typename ...MediaFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Colour }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphAPI.ID.self),
      .field("name", String.self),
      .field("swatch", Swatch?.self),
      .field("media", [Medium]?.self),
    ] }

    /// Unique ID for the colour.
    public var id: BFFGraphAPI.ID { __data["id"] }
    /// The name of the colour.
    public var name: String { __data["name"] }
    /// Image resolver for the colour swatch.
    public var swatch: Swatch? { __data["swatch"] }
    /// The product images for the colour
    public var media: [Medium]? { __data["media"] }

    /// Swatch
    ///
    /// Parent Type: `Image`
    public struct Swatch: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ImageFragment.self),
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

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var imageFragment: ImageFragment { _toFragment() }
      }
    }

    /// Medium
    ///
    /// Parent Type: `Media`
    public struct Medium: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Unions.Media }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MediaFragment.self),
      ] }

      public var asImage: AsImage? { _asInlineFragment() }
      public var asVideo: AsVideo? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var mediaFragment: MediaFragment { _toFragment() }
      }

      /// Medium.AsImage
      ///
      /// Parent Type: `Image`
      public struct AsImage: BFFGraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ColourFragment.Medium
        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ColourFragment.Medium.self,
          MediaFragment.AsImage.self,
          ImageFragment.self
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

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var mediaFragment: MediaFragment { _toFragment() }
          public var imageFragment: ImageFragment { _toFragment() }
        }
      }

      /// Medium.AsVideo
      ///
      /// Parent Type: `Video`
      public struct AsVideo: BFFGraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ColourFragment.Medium
        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Video }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ColourFragment.Medium.self,
          MediaFragment.AsVideo.self
        ] }

        /// A description of the contents of the video for accessibility purposes.
        public var alt: String? { __data["alt"] }
        /// The media content type.
        public var mediaContentType: GraphQLEnum<BFFGraphAPI.MediaContentType> { __data["mediaContentType"] }
        /// The sources for the video.
        public var sources: [Source] { __data["sources"] }
        /// A preview image for the video.
        public var previewImage: PreviewImage? { __data["previewImage"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var mediaFragment: MediaFragment { _toFragment() }
        }

        public typealias Source = MediaFragment.AsVideo.Source

        public typealias PreviewImage = MediaFragment.AsVideo.PreviewImage
      }
    }
  }

}