// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == BFFGraphApi.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == BFFGraphApi.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == BFFGraphApi.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == BFFGraphApi.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return BFFGraphApi.Objects.Query
    case "Product": return BFFGraphApi.Objects.Product
    case "Brand": return BFFGraphApi.Objects.Brand
    case "PriceRange": return BFFGraphApi.Objects.PriceRange
    case "Money": return BFFGraphApi.Objects.Money
    case "KeyValuePair": return BFFGraphApi.Objects.KeyValuePair
    case "Variant": return BFFGraphApi.Objects.Variant
    case "Size": return BFFGraphApi.Objects.Size
    case "SizeGuide": return BFFGraphApi.Objects.SizeGuide
    case "Colour": return BFFGraphApi.Objects.Colour
    case "Price": return BFFGraphApi.Objects.Price
    case "Image": return BFFGraphApi.Objects.Image
    case "Video": return BFFGraphApi.Objects.Video
    case "VideoSource": return BFFGraphApi.Objects.VideoSource
    case "ProductListing": return BFFGraphApi.Objects.ProductListing
    case "Pagination": return BFFGraphApi.Objects.Pagination
    case "NavMenuItem": return BFFGraphApi.Objects.NavMenuItem
    case "Suggestion": return BFFGraphApi.Objects.Suggestion
    case "SuggestionBrand": return BFFGraphApi.Objects.SuggestionBrand
    case "SuggestionKeyword": return BFFGraphApi.Objects.SuggestionKeyword
    case "SuggestionProduct": return BFFGraphApi.Objects.SuggestionProduct
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
