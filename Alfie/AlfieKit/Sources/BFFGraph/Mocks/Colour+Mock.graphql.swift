// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import BFFGraphAPI

public class Colour: MockObject {
  public static let objectType: ApolloAPI.Object = BFFGraphAPI.Objects.Colour
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Colour>>

  public struct MockFields {
    @Field<BFFGraphAPI.ID>("id") public var id
    @Field<[Media]>("media") public var media
    @Field<String>("name") public var name
    @Field<Image>("swatch") public var swatch
  }
}

public extension Mock where O == Colour {
  convenience init(
    id: BFFGraphAPI.ID? = nil,
    media: [(any AnyMock)]? = nil,
    name: String? = nil,
    swatch: Mock<Image>? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setList(media, for: \.media)
    _setScalar(name, for: \.name)
    _setEntity(swatch, for: \.swatch)
  }
}
