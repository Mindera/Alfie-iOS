# Testing

## Rules

Every rule here binds both writing a test and reviewing one. A review is not done until each has been
checked against the diff.

### ✅ ALWAYS

- Write the failing test before the bugfix — it is the proof the bug existed.
- Name the test as a claim about behaviour, in lower_snake segments:
  `test_<trigger>_<condition>_<expectation>`, as in
  `test_state_is_generic_error_when_webview_reports_failure`. Where the test guards against a
  specific wrong outcome, name that outcome:
  `test_non_finite_totals_map_to_no_total_rather_than_zero`. A name that will not stay
  short means the test covers too much. Two small groups of legacy names predate this — `testExample`
  with no prefix, and `test_` on a single camelCase sentence — and are to be renamed, not copied.
- Structure every test **arrange → act → assert**, the three phases separated by blank lines. One
  **act** per test: a single call on the SUT, then assertions about its outcome. Several assertions
  after one act is right, not a smell.
- Build a fresh SUT in `setUpWithError()`, or in a `makeSUT(...)` helper where configurations differ,
  and nil every stored `var` in `tearDownWithError()`. Each test passes alone and in any order. An
  immutable `let` collaborator needs no teardown — XCTest builds a fresh test instance per test.
- Reach every collaborator through a **seam**, never a singleton or a type the SUT constructs itself.
  In a feature or ViewModel test that seam is the feature's `DependencyContainer`, built from the
  `Mock<Service>` types — construct the container rather than bypassing it. A `Core` service test has
  no container: inject the protocol collaborators straight into the initialiser, as
  `ProductListingServiceTests` does.
- Stub a mock by assigning its `on<Method>Called` closure, and **spy** by capturing the arguments
  inside that same closure (navigation into a `capturedRoutes` array).
- Leave an unset mock closure throwing — `guard let x = try onFooCalled?(…) else { throw … }`. A silent
  success lets a test assert an empty result while the mock was never configured at all. The exception
  is an operation whose empty answer is a real answer: `categoryPriceRange` returns `nil` and
  `getHeaderNav` returns `[]` when unset, because absence there is a legitimate outcome.
- Build domain values with `.fixture(...)`, naming only the field the test is about.
- Assert `ViewState` / `PaginatedViewState` transitions with the `XCTAssertEmitsValue*` helpers and
  the named timeout constants in `TestUtils`.
- **Gate** concurrent behaviour: an `actor` that suspends the first call until the test releases it,
  driven with `async let` plus `fulfillment(of:)`. The file-scoped `FetchGate` at the foot of
  `ProductListingViewModelTests.swift` is the reference implementation.
- Give anything ambient — `Date`, `UUID`, schedulers, `Locale`, `TimeZone` — the same seam: a
  parameter defaulting to the real thing, so a test passes a fixed value. `CurrencyFormatter` is the
  reference: it takes `locale:`, so its tests pin `en_GB` and `de_DE` rather than inheriting whatever
  the simulator is set to.
- Compare `Double` and `Float` with `XCTAssertEqual(_:_:accuracy:)`, at the tightest tolerance the
  maths genuinely needs — see §Tolerances.
- Forward `file: StaticString = #filePath, line: UInt = #line` through a new assertion helper, so a
  failure lands on the test rather than on the helper. `trackForMemoryLeak` does this; the
  `XCTAssertEmitsValue*` family does **not**, so its failures report against `XCTestCase+Combine.swift`
  and you read the call site from the stack trace. Adding the two parameters there is a wanted fix,
  and source-compatible across all 140 call sites.
- Cover every state the screen can reach: loading, success, empty, error.
- Write the expected value as a literal. Deriving it from the code under test yields a test that
  passes while both sides share the same bug.

### ❌ NEVER

| Never | Instead |
|---|---|
| Branch in the assert phase — an `if` wrapping an assertion reports green on the run where the branch never fires | Split into separate tests, or drive a table of cases with a per-row failure message. Branching *inside a mock closure* to route on its argument is the stub doing its job, not logic in the test |
| `Task.sleep`, `Thread.sleep` or `asyncAfter` to wait for async work | `await` the call, use the `TestUtils` publisher helpers, or gate it |
| Test a `private` method, or widen access to reach one | Assert the public behaviour that calls it |
| Touch the network, disk, real `UserDefaults` or the real BFF in a unit test | Use a mock — `MockUserDefaults` for defaults; real-BFF coverage belongs in `BFFIntegrationTests`. `ProductListingStyleProviderTests` still drives a real suite and tears it down: debt, not precedent |
| `zip` two collections to pair test inputs | Pair them in one array of tuples — `zip` truncates to the shorter side and drops cases silently |
| Comment out, delete or placeholder (`XCTAssertTrue(true)`) a failing test | Fix it, or `XCTSkip("reason")` with a linked issue |
| Chase a coverage number | Cover the behaviours that would hurt if they broke |
| Set an `accuracy:` looser than the maths needs, or widen one so a failing test goes quiet | Use the tightest value that passes, and name the constant when it budgets something physical. A loose tolerance **blocks the review** — see §Tolerances |
| Loosen snapshot `precision` to absorb a diff | Re-record the reference (`Docs/SnapshotTesting.md`) |
| Assert screen *content* through a snapshot | Snapshot the layout; unit-test the content |
| Leave a test target out of its test plan | Add it — an absent target is skipped silently and still reports green. Unit targets belong to `Alfie.xctestplan` (18 of them); `BFFIntegrationTests` is the sole integration target and belongs to `AlfieIntegration.xctestplan` alone |

### Tolerances

An `accuracy:` is a budget for floating-point error and nothing else. Anything wider silently absorbs
the regression the assertion exists to catch, so **a tolerance looser than the maths needs fails
review** — treat it as a defect in the diff, not a style preference. Two shapes:

- **Computed arithmetic** — `0.001` or tighter. The expected value is exact, so the budget covers
  representation error alone.
- **Measured SwiftUI layout** — the pixel grid, named in a constant so the number is traceable.
  Resolved sizes snap to the grid, so a height lands up to half a pixel off the arithmetic: at
  `displayScale` 3, `300 / 0.77` resolves to 389.667, not 389.610. That makes the budget 1/6pt, so
  `0.2` covers it with headroom.

Read any bare literal above `0.001` as unexamined until someone shows the maths behind it.

**Unswept, and not precedent.** `SnapCarouselHeightTests` is the known case: nine layout assertions
at `accuracy: 1`, roughly 6× wider than the grid requires and enough to hide a real regression, plus
five colour-channel assertions at `accuracy: 0.1` against a 0–1 channel. Tightening the layout nine
to `0.001` was measured: eight still pass, and the ninth exposes a 0.056pt gap that `1` was absorbing
— the grid rounding above. The colour budget needs measuring rather than guessing, since pixel
sampling carries real noise. All fourteen are debt pending a suite-wide tolerance review; match the
rule above in new code rather than copying them.

### Framework

`XCTest` is the house framework; every test in the repo is written against it. Swift Testing
(`@Test` / `#expect`) is **not** adopted, and introducing it is a funded migration rather than a
per-PR choice. Four things block it:

1. The assertion helpers — `XCTAssertEmitsValue*` (140 call sites) and `trackForMemoryLeak` — are
   `XCTestCase` extensions, so a `@Test` function cannot reach them. Porting
   `XCTestCase+Combine.swift` and `XCTestCase+MemoryLeak.swift` is the first move in any migration.
   The rest of `TestUtils` extends `TimeInterval`, `View` and `Snapshotting`, and carries over as is.
2. `XCTAssertEqual(_:_:accuracy:)` has no Swift Testing equivalent, and the carousel-geometry and
   typography tests depend on it throughout.
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
| Feature and service mocks are hand-written, never generated | They double as `#Preview` fixtures, so they live in a production target. A generator would add a third codegen step and make them un-hand-tunable, losing the throwing unset closure. Spying inside the closure already gives call counts. |
| Table-driven `for` loops over cases | XCTest has no parameterized tests; the loop is the workaround. |
| `do { … XCTFail() } catch is SomeError {}` on error paths | The typed `catch` expresses what `XCTAssertThrowsError`'s `Error`-typed closure cannot. One test in the suite uses `XCTAssertThrowsError`; the typed form is the house idiom. |
| No `// Given` / `// When` / `// Then` labels | Blank lines separate the three phases already. Comments are spent on *why* a behaviour matters, citing the acceptance criterion (`(AC 5)`, `(Q36)`). |
| No CI test retries | Retries suit unreliable external services; CI runs the unit plan only, so a flake there is a real bug. |
| Test code is held to this document, not to SwiftLint | `Alfie/.swiftlint.yml` excludes `AlfieKit/Tests` and `AlfieKit/Sources/Mocks`, so no lint runs on either. Review test code against the rules above — naming, seams, the state matrix — and leave formatting alone. Lifting the exclusion is a repo-wide call, not a per-PR one. |


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
