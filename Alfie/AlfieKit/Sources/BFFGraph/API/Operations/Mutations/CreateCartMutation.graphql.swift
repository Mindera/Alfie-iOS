// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class CreateCartMutation: GraphQLMutation {
    public static let operationName: String = "CreateCartMutation"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateCartMutation($input: CreateCartInput!) { createCart(input: $input) { __typename ...CartFragment } }"#,
        fragments: [CartFragment.self, CartItemFragment.self, MoneyFragment.self]
      ))

    public var input: CreateCartInput

    public init(input: CreateCartInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createCart", CreateCart.self, arguments: ["input": .variable("input")]),
      ] }

      public var createCart: CreateCart { __data["createCart"] }

      /// CreateCart
      ///
      /// Parent Type: `Cart`
      public struct CreateCart: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Cart }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(CartFragment.self),
        ] }

        public var id: BFFGraphAPI.ID { __data["id"] }
        public var lineItems: [LineItem] { __data["lineItems"] }
        public var totals: Totals { __data["totals"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var cartFragment: CartFragment { _toFragment() }
        }

        public typealias LineItem = CartFragment.LineItem

        public typealias Totals = CartFragment.Totals
      }
    }
  }

}