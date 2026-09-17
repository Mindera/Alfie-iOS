// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class ProductByBarcodeQuery: GraphQLQuery {
    public static let operationName: String = "ProductByBarcodeQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ProductByBarcodeQuery($barcode: String!) { productByBarcode(barcode: $barcode) { __typename id variantId } }"#
      ))

    public var barcode: String

    public init(barcode: String) {
      self.barcode = barcode
    }

    public var __variables: Variables? { ["barcode": barcode] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("productByBarcode", ProductByBarcode?.self, arguments: ["barcode": .variable("barcode")]),
      ] }

      public var productByBarcode: ProductByBarcode? { __data["productByBarcode"] }

      /// ProductByBarcode
      ///
      /// Parent Type: `BarcodeMatch`
      public struct ProductByBarcode: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.BarcodeMatch }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BFFGraphAPI.ID.self),
          .field("variantId", BFFGraphAPI.ID?.self),
        ] }

        public var id: BFFGraphAPI.ID { __data["id"] }
        public var variantId: BFFGraphAPI.ID? { __data["variantId"] }
      }
    }
  }

}