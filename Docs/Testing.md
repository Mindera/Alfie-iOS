# Testing

## Test Structure

- **Location**: `Alfie/AlfieKit/Tests/` — one test target per module, named `<Module>Tests`
  (`ls Alfie/AlfieKit/Tests/` for the current set). `BFFIntegrationTests` is the odd one out:
  it runs against a real local BFF, not mocks, and only when `verify.sh` runs without
  `--skip-integration`.

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
- Record mode: Set `isRecording = true` temporarily
- Verify mode: Default behavior
- Tests live in the AlfieKit module test targets; shared helpers are in `TestUtils`
- References are pinned to iOS major 26 and run as part of `./Alfie/scripts/verify.sh`

See `Docs/SnapshotTesting.md` for the device/precision policy, the record loop, and where the tests live.
