// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct MediaFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MediaFragment on Media { __typename ... on Image { ...ImageFragment } ... on Video { alt mediaContentType sources { __typename format mimeType url } previewImage { __typename ...ImageFragment } } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Unions.Media }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsImage.self),
      .inlineFragment(AsVideo.self),
    ] }

    public var asImage: AsImage? { _asInlineFragment() }
    public var asVideo: AsVideo? { _asInlineFragment() }

    /// AsImage
    ///
    /// Parent Type: `Image`
    public struct AsImage: BFFGraphAPI.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MediaFragment
      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
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

    /// AsVideo
    ///
    /// Parent Type: `Video`
    public struct AsVideo: BFFGraphAPI.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = MediaFragment
      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Video }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("alt", String?.self),
        .field("mediaContentType", GraphQLEnum<BFFGraphAPI.MediaContentType>.self),
        .field("sources", [Source].self),
        .field("previewImage", PreviewImage?.self),
      ] }

      /// A description of the contents of the video for accessibility purposes.
      public var alt: String? { __data["alt"] }
      /// The media content type.
      public var mediaContentType: GraphQLEnum<BFFGraphAPI.MediaContentType> { __data["mediaContentType"] }
      /// The sources for the video.
      public var sources: [Source] { __data["sources"] }
      /// A preview image for the video.
      public var previewImage: PreviewImage? { __data["previewImage"] }

      /// AsVideo.Source
      ///
      /// Parent Type: `VideoSource`
      public struct Source: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.VideoSource }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("format", GraphQLEnum<BFFGraphAPI.VideoFormat>.self),
          .field("mimeType", String.self),
          .field("url", BFFGraphAPI.URL.self),
        ] }

        /// The format of the video source.
        public var format: GraphQLEnum<BFFGraphAPI.VideoFormat> { __data["format"] }
        /// The video MIME type.
        public var mimeType: String { __data["mimeType"] }
        /// The URL of the video.
        public var url: BFFGraphAPI.URL { __data["url"] }
      }

      /// AsVideo.PreviewImage
      ///
      /// Parent Type: `Image`
      public struct PreviewImage: BFFGraphAPI.SelectionSet {
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
    }
  }

}