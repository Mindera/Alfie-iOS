# Testing

## Rules

Every rule here binds both writing a test and reviewing one. A review is not done until each has been
checked against the diff.

### ✅ ALWAYS

- Write the failing test before the bugfix — it is the proof the bug existed.
- Name the test as a claim about behaviour: `test_<trigger>_<condition>_<expectation>`. Where the test
  guards against a specific wrong outcome, name that outcome:
  `test_aShopperWithNoCartSeesAnEmptyBagRatherThanAnError`. A name that will not stay short means the
  test covers too much.
- Give each test one **act**: one call on the SUT, then assertions about its outcome. Several
  assertions after a single act is right, not a smell.
- Build a fresh SUT in `setUpWithError()`, or in a `makeSUT(...)` helper where configurations differ,
  and nil every stored reference in `tearDownWithError()`. Each test passes alone and in any order.
- Reach every collaborator through a **seam**: the feature's `DependencyContainer`, built in the test
  from the `Mock<Service>` types. Construct the container rather than bypassing it.
- Stub a mock by assigning its `on<Method>Called` closure, and **spy** by capturing the arguments
  inside that same closure (navigation into a `capturedRoutes` array).
- Leave an unset mock closure throwing. A silent success lets a test assert an empty result while the
  mock was never configured at all.
- Build domain values with `.fixture(...)`, naming only the field the test is about.
- Assert `ViewState` / `PaginatedViewState` transitions with the `XCTAssertEmitsValue*` helpers and
  the named timeout constants in `TestUtils`.
- **Gate** concurrent behaviour: an `actor` that suspends the first call until the test releases it,
  driven with `async let` plus `fulfillment(of:)`. `ProductListingViewModelTests.FetchGate` is the
  reference implementation.
- Give anything ambient — `Date`, `UUID`, schedulers — the same seam: a parameter defaulting to the
  real thing, so a test passes a fixed value.
- Compare `Double` and `Float` with `XCTAssertEqual(_:_:accuracy:)`.
- Forward `file: StaticString = #filePath, line: UInt = #line` through every assertion helper, so a
  failure lands on the test rather than on the helper.
- Cover every state the screen can reach: loading, success, empty, error.
- Write the expected value as a literal. Deriving it from the code under test yields a test that
  passes while both sides share the same bug.

### ❌ NEVER

| Never | Instead |
|---|---|
| Branch in a test the way the implementation branches | Split into separate tests, or drive a table of cases with a per-row failure message |
| `Task.sleep`, `Thread.sleep` or `asyncAfter` to wait for async work | `await` the call, use the `TestUtils` publisher helpers, or gate it |
| Test a `private` method, or widen access to reach one | Assert the public behaviour that calls it |
| Touch the network, disk, real `UserDefaults` or the real BFF in a unit test | Use a mock; real-BFF coverage belongs in `BFFIntegrationTests` |
| `zip` two collections to pair test inputs | Pair them in one array of tuples — `zip` truncates to the shorter side and drops cases silently |
| Comment out, delete or placeholder (`XCTAssertTrue(true)`) a failing test | Fix it, or `XCTSkip("reason")` with a linked issue |
| Chase a coverage number | Cover the behaviours that would hurt if they broke |
| Loosen snapshot `precision` to absorb a diff | Re-record the reference (`Docs/SnapshotTesting.md`) |
| Assert screen *content* through a snapshot | Snapshot the layout; unit-test the content |
| Leave a test target out of `Alfie.xctestplan` | Add it — an absent target is skipped silently and still reports green |

### Framework

`XCTest` is the house framework; every test in the repo is written against it. Swift Testing
(`@Test` / `#expect`) is **not** adopted, and introducing it is a funded migration rather than a
per-PR choice. Four things block it:

1. Every shared helper in `TestUtils` — `XCTAssertEmitsValue*`, `trackForMemoryLeak`, the named
   timeout constants — is an `XCTestCase` extension, so a `@Test` function cannot reach any of them.
   Porting `TestUtils` is the first move in any migration.
2. `XCTAssertEqual(_:_:accuracy:)` has no Swift Testing equivalent; the typography and range-slider
   tests depend on it.
3. `Package.swift` declares `swift-tools-version: 5.9`. Whether SwiftPM enables Swift Testing below
   6.0 is unresolved — settle that before proposing adoption.
4. The package builds in Swift 5 language mode with no strict-concurrency opt-in. Swift Testing runs
   tests on arbitrary tasks, so the data-race warnings would all land at once.

UI and performance tests stay on XCTest whatever happens: Apple does not support `XCUIApplication`
or `XCTMetric` under Swift Testing.

## Settled

General iOS testing advice argues against each of these, and each is a deliberate choice here.
Treat them as correct, in review and when writing.

| Choice | Why it stands |
|---|---|
| Mocks are hand-written, never generated | They double as `#Preview` fixtures, so they live in a production target. A generator would add a third codegen step and make them un-hand-tunable, losing the throwing unset closure. Spying inside the closure already gives call counts. |
| Table-driven `for` loops over cases | XCTest has no parameterized tests; the loop is the workaround. |
| `do { … XCTFail() } catch is SomeError {}` on error paths | The typed `catch` expresses what `XCTAssertThrowsError`'s `Error`-typed closure cannot. One test in the suite uses `XCTAssertThrowsError`; the typed form is the house idiom. |
| No `// Given` / `// When` / `// Then` labels | Blank lines separate the three phases already. Comments are spent on *why* a behaviour matters, citing the acceptance criterion (`(AC 5)`, `(Q36)`). |
| No CI test retries | Retries suit unreliable external services; CI runs the unit plan only, so a flake there is a real bug. |


## Test Structure

- **Location**: `Alfie/AlfieKit/Tests/` — one test target per module, named `<Module>Tests`
  (`ls Alfie/AlfieKit/Tests/` for the current set). `BFFIntegrationTests` is the odd one out:
  it runs against a real local BFF, not mocks, and only when `verify.sh` runs without
  `--skip-integration`.

## Mocks and fixtures

Under `Alfie/AlfieKit/Sources/Mocks/`: `Core/Features/` for mock ViewModels, `Core/Services/` for
mock services, `Fixtures/` for the `.fixture(...)` builders. BFF mocks are Apollo-generated under
`Sources/BFFGraph/Mocks/` — regenerate them rather than editing.

`Mocks` is a production `.target`, not a test target: `AppFeature` and `DebugMenu` depend on it for
`#Preview`s, so anything added there ships in the app binary.

## Snapshot Testing

Snapshot tests live in the module test targets and run as part of `verify.sh`. See
`Docs/SnapshotTesting.md` for the device/OS pin, the precision policy, and the record loop.

## Code Coverage

Coverage is a diagnostic, never a target: read it to find a behaviour nobody exercised.

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
