# Testing

## Test Structure

- **Location**: `Alfie/AlfieKit/Tests/` — one test target per module, named `<Module>Tests`
  (`ls Alfie/AlfieKit/Tests/` for the current set). `BFFIntegrationTests` is the odd one out:
  it runs against a real local BFF, not mocks, and only when `verify.sh` runs without
  `--skip-integration`.

## Mocking

- **Mock ViewModels**: Located in `Alfie/AlfieKit/Sources/Mocks/Core/Features/`
- **Mock Services**: Located in `Alfie/AlfieKit/Sources/Mocks/Core/Services/`
- **BFF Mocks**: Located in `Alfie/AlfieKit/Sources/BFFGraph/Mocks/` (Apollo-generated)
- **Fixtures**: Located in `Alfie/AlfieKit/Sources/Mocks/Fixtures/`
- **Pattern**: Conform to same protocol as real implementation

## Snapshot Testing

Snapshot tests live in the module test targets and run as part of `verify.sh`. See
`Docs/SnapshotTesting.md` for the device/OS pin, the precision policy, and the record loop.
