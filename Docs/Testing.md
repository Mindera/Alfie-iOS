# Testing

## Test Structure

- **Location**: `Alfie/AlfieKit/Tests/`
- Test directories mirror feature modules:
  - **AppFeatureTests**: App shell tests
  - **CoreTests**: Core services tests
  - **HomeTests**: Home feature tests
  - **ProductListingTests**: Product listing tests
  - **ProductDetailsTests**: Product details tests
  - **SearchTests**: Search tests
  - **CategorySelectorTests**: Category selector tests
  - **WishlistTests**: Wishlist tests
  - **BagTests**: Bag tests
  - **SharedUITests**: Localization and UI tests
  - **DeepLinkTests**: Deep link tests
  - **DebugMenuTests**: Debug menu tests
  - **WebTests**: Web view tests
  - **MyAccountTests**: Account tests
  - **BFFGraphTests**: GraphQL tests
  - **UtilsTests**: Utility tests

## Testing Pattern

```swift
final class FeatureServiceTests: XCTestCase {
    func testFetchDataSuccess() async throws {
        // Given
        let mockBFFClient = MockBFFClientService()
        let service = FeatureService(bffClient: mockBFFClient)
        
        // When
        let result = try await service.fetchData()
        
        // Then
        XCTAssertEqual(result.id, "expected-id")
    }
}
```

## Mocking

- **Mock ViewModels**: Located in `Alfie/AlfieKit/Sources/Mocks/Core/Features/`
- **Mock Services**: Located in `Alfie/AlfieKit/Sources/Mocks/Core/Services/`
- **BFF Mocks**: Located in `Alfie/AlfieKit/Sources/BFFGraph/Mocks/` (Apollo-generated)
- **Fixtures**: Located in `Alfie/AlfieKit/Sources/Mocks/Fixtures/`
- **Pattern**: Conform to same protocol as real implementation

## Snapshot Testing

- Uses `swift-snapshot-testing` library
- Record mode: Set `record = true` temporarily
- Verify mode: Default behavior
