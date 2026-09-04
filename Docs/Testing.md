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

## Code Coverage

An unfiltered `verify.sh` run leaves a coverage bundle at `/tmp/alfie_test.xcresult`. Read it with:

```bash
xcrun xccov view --report --json /tmp/alfie_test.xcresult
```

Beside it, `/tmp/alfie_test.xcresult.sha` says what the bundle describes:

```
<commit sha>
snapshots=included|skipped
```

Treat the bundle as unusable unless both lines check out. The sha is the commit the run measured, so
it going stale against `HEAD` means the coverage predates your edits; note it is commit-granular, so
it cannot tell you the tree was dirty. `snapshots=skipped` means SwiftUI `body` declarations read as
uncovered because nothing executed them, which is a measurement gap rather than a missing test.

Two things the bundle does not cover. A `--filter` run writes to
`/tmp/alfie_test_filtered.xcresult` and is never stamped, because its coverage describes a subset of
the suite. And `AlfieIntegration.xctestplan` collects nothing, so anything exercised only by
`BFFIntegrationTests` reads as 0%.

Coverage is off in CI (`SCAN_CODE_COVERAGE=false` in `fastlane/.env.default`): the run has no
consumer there, and the xcresult is uploaded only on failure.
