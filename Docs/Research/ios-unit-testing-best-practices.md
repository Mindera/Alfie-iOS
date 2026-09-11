# iOS / Swift unit testing best practices

**Date:** 2026-09-11
**Question:** What are the best practices for unit testing on iOS/Swift, distilled into rules the repo
can adopt?
**Status:** Evidence behind `Docs/Testing.md` §Rules, which is where the ruleset landed. Read that for
the rules; read this for why each one is there, and for what was considered and rejected. No
`CODING-STANDARD.md` was created — `Docs/Testing.md` already owned the `AGENTS.md` pointer.

## Sources consulted

**Named secondary sources (read in full)**

| Source | URL |
|---|---|
| marcin-bo, *Unit Testing in Swift* (README + sub-pages) | <https://github.com/marcin-bo/Unit-Testing-In-Swift> |
| — *Unit Testing Best Practices in Swift* | <https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Best%20Practices%20in%20Swift.md> |
| — *Unit Testing Terminology* (test-double taxonomy) | <https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Terminology.md> |
| — *Unit Testing Patterns in Swift* | <https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Patterns%20in%20Swift.md> |
| Antoine van der Lee, *Unit tests best practices in Swift* | <https://www.avanderlee.com/swift/unit-tests-best-practices/> |
| AvdLee, *Swift Testing Agent Skill* — `SKILL.md` + all 10 `references/*.md` | <https://github.com/AvdLee/Swift-Testing-Agent-Skill> |

**Primary sources (claims chased back to the owner)**

| Source | URL |
|---|---|
| Swift Testing — `Testing.docc` (the source of `developer.apple.com/documentation/testing`) | <https://github.com/swiftlang/swift-testing/tree/main/Sources/Testing/Testing.docc> |
| — `MigratingFromXCTest.md` | <https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md> |
| — `Parallelization.md` | <https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Parallelization.md> |
| — `ParameterizedTesting.md` | <https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md> |
| — `Expectations.md`, `DefiningTests.md`, `OrganizingTests.md`, `known-issues.md`, `testing-asynchronous-code.md` | same directory |
| swift-testing `README.md` / `Documentation/Distributions.md` | <https://github.com/swiftlang/swift-testing/blob/main/Documentation/Distributions.md> |
| Apple, WWDC24 *Meet Swift Testing* | <https://developer.apple.com/videos/play/wwdc2024/10179/> |
| Apple, WWDC22 *Author fast and reliable tests for Xcode Cloud* | <https://developer.apple.com/videos/play/wwdc2022/110361/> |
| Apple, XCTest framework reference | <https://developer.apple.com/documentation/xctest> |
| Apple, Swift Testing product page | <https://developer.apple.com/xcode/swift-testing/> |

**Repo evidence** — `Alfie/AlfieKit/Package.swift`, `Alfie/AlfieKit/Tests/` (91 files, 911 test
functions, 84 `XCTestCase` subclasses), `Alfie/AlfieKit/Sources/Mocks/` (51 files),
`Alfie/AlfieKit/Sources/TestUtils/` (5 files), `Alfie/Alfie/Alfie.xctestplan`,
`Alfie/Alfie/AlfieIntegration.xctestplan`, `Alfie/Alfie.xcodeproj/xcshareddata/xcschemes/Alfie.xcscheme`,
`Alfie/.swiftlint.yml`, `Alfie/scripts/test-for-verification.sh`, `fastlane/.env.default`,
`fastlane/Fastfile`, `.github/workflows/alfie.yml`, `Docs/Testing.md`, `Docs/SnapshotTesting.md`,
`Docs/Architecture.md`, `Docs/CodeStyle.md`, `CLAUDE.md`.

---

# TL;DR — the proposed ruleset (superseded)

*This draft shipped as `Docs/Testing.md` §Rules, pruned on the way: stale counts and file paths the
repo already answers, rules the compiler or a competent author applies by default, and the
`CODING-STANDARD.md` framing all came out. **`Docs/Testing.md` is the authority; this is the draft
it came from.** Each rule's evidence is below; the repo's status for each is in the
[gap analysis](#repo-gap-analysis).*

## Testing

Tests live in `Alfie/AlfieKit/Tests/<Module>Tests`, must be listed in `Alfie/Alfie/Alfie.xctestplan`,
and must pass under `./Alfie/scripts/verify.sh`.

### ✅ ALWAYS

- Write the test **before** fixing a bug — the failing test is the proof the bug existed.
- Name tests `test_<trigger>_<condition>_<expectation>` in snake_case, phrased as a claim about
  behaviour. If you cannot name it shortly, the test covers too much.
- Give each test one **act**: one call on the SUT, then assertions about its outcome.
- Build the SUT in `setUpWithError()` (or a `makeSUT(...)` helper) and nil every stored reference in
  `tearDownWithError()`. A test must not depend on any other test, in any order.
- Inject every collaborator as a protocol through the feature's `DependencyContainer`, constructed in
  the test from the hand-written `Mock<Service>` types in
  `Alfie/AlfieKit/Sources/Mocks/Core/Services/`.
- Stub a mock by assigning its `on<Method>Called` closure. Capture arguments inside that closure, and
  navigation into a `capturedRoutes` array — that is how this repo spies.
- Leave a mock's unset closure **throwing**, never silently succeeding: an unconfigured mock must fail
  the test, not pass it.
- Build domain values with the `.fixture(...)` factories in `Alfie/AlfieKit/Sources/Mocks/Fixtures/`,
  naming only the field the test is about.
- Assert `ViewState` / `PaginatedViewState` transitions with the `XCTAssertEmitsValue*` helpers in
  `TestUtils`, and use the named timeouts `.default` (2.0s) and `.inverted` (0.01s).
- Use the narrowest assertion available: `XCTAssertEqual` over `XCTAssertTrue(a == b)`,
  `XCTAssertNil` over `XCTAssertTrue(x == nil)`, `try XCTUnwrap` over force-unwrap.
- Compare `Double` / `Float` with `XCTAssertEqual(_:_:accuracy:)`.
- Forward `file: StaticString = #filePath, line: UInt = #line` from every assertion helper, so the
  failure lands on the test, not the helper.
- Cover the full state matrix — loading, success, **empty**, error — not just the happy path.
- Gate genuinely concurrent behaviour with an `actor` gate and `fulfillment(of:)`, the way
  `ProductListingViewModelTests.FetchGate` does — never with a sleep.
- Inject `Date`, `UUID` and schedulers as parameters (default to the real thing in production, pass a
  fixture or `AnySchedulerOf`/`TestScheduler` in tests).
- Comment *why* a non-obvious behaviour matters, not what the code does.
- Treat test code as production code: same review bar, same naming, same lint rules.

### ❌ NEVER

| Never | Instead |
|---|---|
| Branch inside a test (`if`, `switch`, `for`, `do/catch`) | Split into separate tests, or drive a table of cases |
| `Task.sleep`, `Thread.sleep`, or `asyncAfter` to wait for async work | `await` the call, use the `TestUtils` publisher helpers, or an `actor` gate |
| Test a `private` method, or widen access just to test | Assert the public behaviour that calls it |
| Hit the network, disk, real `UserDefaults`, or the real BFF in a unit test | Use a mock; real-BFF coverage belongs in `BFFIntegrationTests` |
| `XCTAssert(x == y)` | `XCTAssertEqual(x, y)` |
| Comment out, delete, or placeholder (`XCTAssertTrue(true)`) a test | Fix it, or `XCTSkip("reason")` with a linked issue |
| Chase a coverage number | Cover the behaviours that would hurt if they broke |
| Loosen snapshot `precision` to hide a rendering diff | Re-record the reference (`Docs/SnapshotTesting.md`) |
| Assert screen *content* only through a snapshot | Snapshot the layout; unit-test the content |
| Leave a test target out of `Alfie.xctestplan` | Add it — an absent target is silently skipped and still reports green |

### Framework

`XCTest` is the house framework. Swift Testing (`@Test` / `#expect`) is **not** adopted here — do not
introduce it in a feature PR. Adopting it is a deliberate, separate migration; the cost and blockers
are in `Docs/Research/ios-unit-testing-best-practices.md` §9.

---

# Detailed findings

## 1. Naming and structure

**Name the test after the behaviour, not the method.** marcin-bo proposes
`test_methodName_whenCondition_shouldExpectation` or `test_behaviour_whenCondition_shouldExpectation`
([Best Practices §Name the Test Properly](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Best%20Practices%20in%20Swift.md)).
van der Lee frames the same idea as a smell test: if you cannot devise a short name, "you're likely
testing too many things simultaneously"
([avanderlee §Naming test cases and methods](https://www.avanderlee.com/swift/unit-tests-best-practices/)).
Both are **author opinion** — no Apple document prescribes a test-name grammar. XCTest only requires
the `test` prefix for discovery ([XCTest](https://developer.apple.com/documentation/xctest)); Swift
Testing removes even that, identifying tests by the `@Test` attribute
([DefiningTests.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/DefiningTests.md)).

**Repo:** already strong, in two coexisting dialects. 912 of 919 test functions use `test_…`
snake/camel hybrid; 7 are camelCase legacy (`testExample`, `testLocalizationTables`, `testTable`,
`testFixture`). Dialect (a) is a full behavioural sentence
(`test_aShopperWithNoCartSeesAnEmptyBagRatherThanAnError`,
`test_non_finite_totals_map_to_no_total_rather_than_zero`); dialect (b) is
`test_<method>_<condition>_<expectation>` (`test_viewDidAppear_whenTheReadFails_showsTheError`). The
"X rather than Y" form that names the failure being guarded against is a genuinely good local
invention. The convention is *de facto* and undocumented.

**Arrange-Act-Assert / Given-When-Then.** marcin-bo's AAA section is imported from
[Microsoft's .NET unit-testing guidance](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices),
which he cites — a cross-language convention, not a Swift or Apple one. The Swift Testing skill states
the underlying goal without the ceremony: "Keep each test focused on one behavior"
([`references/fundamentals.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/fundamentals.md)).

**Repo:** the three-phase shape is present but unlabelled — **zero** files carry `// Given` / `// When`
/ `// Then` comments; 7 occurrences of `// Arrange` / `// Act` / `// Assert` in total. Structure comes
from blank-line-separated paragraphs plus `// MARK: -` section headers and a trailing
`// MARK: - Helpers`. Comments are spent on *why* a behaviour matters, often citing acceptance
criteria (`(Q36)`, `(AC 5)`) — more valuable than restating the phase. Ironically the only file that
*mentions* Given-When-Then is the empty placeholder `Tests/UtilsTests/UtilsTests.swift`, which says
"Add Utils tests here following the Given-When-Then pattern" and contains `XCTAssertTrue(true)`.
**Judgement: do not mandate AAA comments; do delete the placeholder.**

**Suites and setup (Swift Testing).** Apple replaces `XCTestCase` subclasses with plain `struct`
suites and `setUp`/`tearDown` with `init()`/`deinit`, and explicitly recommends struct or actor over
class "because it allows the Swift compiler to better-enforce concurrency safety"
([MigratingFromXCTest.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md)).
Instance test methods each run on a **distinct instance** of the suite type
([OrganizingTests.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/OrganizingTests.md)) —
that is where per-test isolation comes from for free.

## 2. Test independence and setup/teardown

Apple's own guidance is the strongest primary citation in this whole document:

> "Note that tests must be designed to run independently to take advantage of parallel execution.
> Proper setup and teardown are essential to reliable test case behavior."
> — [WWDC22, *Author fast and reliable tests for Xcode Cloud*](https://developer.apple.com/videos/play/wwdc2022/110361/)

and, on where state belongs:

> "Note that rather than relying on teardown methods to prepare for subsequent tests, we recommend
> establishing all state preparation in the setup method." — *ibid.*

marcin-bo agrees ("Each test should handle its own setup and tear down") and adds the counterweight:
building the SUT in `setUp()` can itself create coupling, so prefer a `makeSUT()` factory when
configurations differ
([Best Practices §Use the Power of Helper Methods](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Best%20Practices%20in%20Swift.md)).

**Repo:** `setUpWithError` is the house standard (29 files), with 7 more using `setUp` including the
one `async throws` setUp in `BFFIntegrationTests/IntegrationTestCase.swift`; 33 files implement
teardown; 56 use a `sut`. The idiom is strict and consistent: implicitly-unwrapped optional
properties, `try super.setUpWithError()` first, every property nilled in `tearDownWithError`,
`try super.tearDownWithError()` last. 18 `makeSUT`-style factories exist alongside for parameterised
variants. No cross-test global mutable state was found.

## 3. Test doubles and mocking

marcin-bo gives the cleanest taxonomy of the three sources
([Terminology](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Terminology.md),
derived from [xUnit Patterns](http://xunitpatterns.com/Test%20Double.html)):

| Double | Simulates behaviour? | Observes interactions? | Real implementation? |
|---|---|---|---|
| Dummy | no | no | no |
| Stub | yes | no | no |
| Fake | yes | no | yes (simplified) |
| Spy | no | yes | yes |
| Mock | yes | yes | no |

He then recommends **generating** mocks with [Sourcery](https://github.com/krzysztofzablocki/Sourcery)
`AutoMockable`, which yields call counts, received parameters and invocation lists for free. This is
**author opinion** and is the one place the three sources meaningfully disagree — see
[Contradictions](#contradictions--judgement-calls). The Swift Testing skill takes the opposite tack,
recommending hand-written in-memory fakes
([`references/performance-and-best-practices.md` §4](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/performance-and-best-practices.md)).
van der Lee does not discuss mocking at all in the named article. **Apple documents no mocking
facility — there is no primary source here. It is a team choice.**

**Repo:** 51 hand-written files under `Alfie/AlfieKit/Sources/Mocks/` — 30 service mocks, 11 mock
ViewModels, 10 fixture files. No Sourcery, Mockolo, swift-mocking or `.stencil` anywhere in the tree.
Naming is `Mock<Protocol>`, never `<Protocol>Mock`. The idiom is a **closure stub that doubles as a
spy**:

```swift
public var onGetProductCalled: ((String) throws -> Product)?
public func getProduct(handle: String) async throws -> Product {
    guard let product = try onGetProductCalled?(handle) else {
        throw BFFRequestError(type: .emptyResponse)
    }
    return product
}
```
— `Alfie/AlfieKit/Sources/Mocks/Core/Services/MockProductService.swift`

Three properties of this pattern are worth writing into the standard because they are deliberate and
easy to break:

1. **The closure receives the arguments**, so a test captures them into a local `var` and returns the
   canned value in one expression. That is this repo's spy mechanism. Explicit counters exist in only
   one mock — `MockAnalyticsTracker.trackedActions` — where asserting a call did *not* happen needs a
   record.
2. **An unset closure throws.** `MockCartService.fetch()` carries the rationale in a comment: "A
   silent success would let a test assert an empty bag while the mock was never configured at all."
3. **Stateful mocks hold real state** (`MockCartService` a `CurrentValueSubject<Cart?, Never>`,
   `MockWishlistService` a `[SelectedProduct]`), so publisher plumbing is genuinely exercised — these
   are *fakes*, not stubs, in the taxonomy above.

Fixtures are `Type+Fixture.swift` with `static func fixture(…)` and every parameter defaulted —
textbook test-data builders. `Mocks` is a **production `.target`**, depended on by `AppFeature`,
`DebugMenu` and `SharedUI` for SwiftUI previews. That is fine for XCTest, but flags a constraint for
any Swift Testing migration:

> "Only import the testing library into a test target or library meant for test targets… Test
> functions aren't stripped from binaries when building for release, so logic and fixtures of a test
> may be visible to anyone who inspects a build product that contains a test function."
> — [DefiningTests.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/DefiningTests.md)

The warning is about `import Testing`, not about mocks, so the repo is not in breach today.

## 4. Async and concurrency

**Prefer `await` to expectations.** Apple: "Wherever possible, prefer to use Swift concurrency to
validate asynchronous conditions… For a function that takes a completion handler but which doesn't
use `await`, a Swift continuation can be used to convert the call into an `async`-compatible one"
([MigratingFromXCTest.md §Validate asynchronous behaviors](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md)).
WWDC22 makes the reliability argument directly: replacing a timeout-driven expectation with
async/await "allows the test to pause until the await call finishes without any timeout"
([WWDC22 110361](https://developer.apple.com/videos/play/wwdc2022/110361/)).

**Confirmations are the Swift Testing replacement for `XCTestExpectation`**, and differ in kind: they
"don't block or suspend the caller while waiting for a condition to be fulfilled. Instead, the
requirement is expected to be *confirmed*… before `confirmation()` returns" (*ibid.*).
`expectedCount:` takes an exact count or any range with a lower bound; `expectedCount: 0` asserts an
event does **not** happen
([testing-asynchronous-code.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-asynchronous-code.md))
— the analogue of XCTest's `expectation.isInverted`, which marcin-bo documents for the same purpose
([Patterns §How To Check That a Callback is Not Called](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Patterns%20in%20Swift.md)).

**Main-actor isolation differs between the frameworks** — a migration trap worth writing down:

> "XCTest runs synchronous test methods on the main actor by default, while the testing library runs
> all test functions on an arbitrary task. If a test function must run on the main thread, isolate it
> to the main actor with `@MainActor`."
> — [MigratingFromXCTest.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md)

The skill adds that over-applying `@MainActor` "can reduce useful parallelization"
([`references/performance-and-best-practices.md` §2](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/performance-and-best-practices.md))
— plausible, but I found no Apple document quantifying it. Treat as the skill author's judgement.

**Repo:** 94 `expectation(` call sites and 66 `wait(for:` / `fulfillment(of:` sites — and **zero**
`Task.sleep`, `Thread.sleep` or test-side `asyncAfter`. That is the right result. Most waiting is
funnelled through `Alfie/AlfieKit/Sources/TestUtils/Helpers/XCTestCase+Combine.swift`, which wraps the
`@Published` → publisher shape the MVVM layer actually exposes:

```swift
public func XCTAssertEmitsValue<P: Publisher>(
    from publisher: P,
    where predicate: @escaping (P.Output) -> Bool = { _ in true },
    afterTrigger eventTrigger: @escaping () -> Void = {},
    timeout: TimeInterval = .default
) -> P.Output? where P.Failure == Never
```

with a `.drop(untilOutputFrom:)` so a `CurrentValue` replay is skipped and only post-trigger emissions
count, and `XCTAssertNoEmit` using an inverted expectation. Because the ViewModels publish state via
Combine rather than returning from `async` functions, awaiting is not available — the publisher helper
is the right tool, and it is deterministic on success (it returns as soon as the predicate matches;
the timeout is only the failure path). Timeouts are named constants in
`TestUtils/Helpers/TimeInterval+Extension.swift`: `.default = 2.0`, `.inverted = 0.01`.

Two more idioms worth codifying because they are strictly better than what the external sources
propose:

- **Deterministic concurrency via an `actor` gate** rather than sleeps —
  `Tests/ProductListingTests/ProductListingViewModelTests.swift` defines a `FetchGate` actor that
  suspends the first fetch until released and counts entries, driven with
  `async let firstRefresh: Void = sut.refresh()` + `await fulfillment(of: [firstFetchInFlight], timeout: 1)`.
  A sibling gate exists in `CoreTests/ServiceTests/CartServiceTests.swift`. No external source in this
  research describes this pattern.
- **`TestSchedulerOf<DispatchQueue>`** from [`pointfreeco/combine-schedulers`](https://github.com/pointfreeco/combine-schedulers)
  in `Tests/DeepLinkTests/Handlers/DeepLinkHandlerTests.swift` (`DispatchQueue.test`,
  `testScheduler.advance()`), with `.immediate` for the non-time-dependent variants. Only one test
  file uses it; `ProductDetailsDependencyContainer` is the only container carrying an
  `AnySchedulerOf<DispatchQueue>` seam.

## 5. Determinism and flakiness

Apple's WWDC22 session is the best primary source, and names concrete causes
([WWDC22 110361](https://developer.apple.com/videos/play/wwdc2022/110361/)):

| Cause | Apple's fix |
|---|---|
| Time-zone dependence | "Tests should avoid being time zone specific." |
| Locale assumptions | "Avoid this problem by explicitly setting your simulator's locale." |
| Device permissions | "It's best to mock device permissions in a unit test and use an alert handler in a UI Test." |
| Preloaded data | Prepare state in `setUp()`, not by relying on a previous test's teardown |
| Timeout-based waits | Replace with `async` / `await` |
| External services | Mock them — "Advantages of a mocked service include deterministic reliability and speed." |

Apple also documents two safety valves in the test plan: an **execution time allowance** ("the number
of seconds for a test to run before it fails with a timeout error… the default is 600 seconds") and
**test repetitions** in `repeat-until-failure` mode (to reproduce a flake locally) or
`retry-on-failure` mode (for tests depending on an unreliable external service) — with the caveat that
"unnecessary repetitions are wasteful."

The skill's flakiness checklist is consistent and adds nothing Apple contradicts: no order dependence,
no unreset global singletons, no arbitrary sleeps, no hidden external dependencies, "deterministic
fixtures and stable clocks/random sources"
([`references/performance-and-best-practices.md` §8](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/performance-and-best-practices.md)).

marcin-bo's FIRST acronym (Fast / Isolated / Repeatable / Self-validating / Timely) is a useful
mnemonic for the same content. It predates all three sources — it is neither his nor Apple's.

**Repo:** the live flakiness source is snapshot rendering drift across iOS minors, and it is handled
unusually well — `SNAPSHOT_OS_VERSION=26.4` in `Alfie/scripts/test-for-verification.sh` and
`SCAN_DEVICE=iPhone 17 Pro (26.4)` in `fastlane/.env.default` must stay in lockstep, and
`scan(ensure_devices_found: true)` in `fastlane/Fastfile` fails hard rather than silently falling back
to the newest runtime. `Docs/SnapshotTesting.md` records the measurement: ~24 px of glyph drift per
screen between 26.2 and 26.4, enough to fail `precision: 1.0`. A **locale and time-zone pin is
absent**, and is the one item from Apple's table the repo does not cover.

## 6. Dates, UUIDs and randomness

No Apple document prescribes injecting a clock. The skill states it as "deterministic fixtures and
stable clocks/random sources"
([`references/performance-and-best-practices.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/performance-and-best-practices.md));
Apple states it indirectly by telling you not to be time-zone dependent
([WWDC22 110361](https://developer.apple.com/videos/play/wwdc2022/110361/)). The Swift 5.7
[`Clock` protocol](https://developer.apple.com/documentation/swift/clock) exists for this, but testing
against it needs a controllable implementation the standard library does not ship.

**Repo:** the codebase is almost entirely time-independent rather than carefully abstracted. There is
exactly **one** `Date()` in non-mock, non-generated source, and it is already a default-parameter seam:

```swift
static func parse(headerValue: String?, now: Date = Date()) -> TimeInterval? {
```
— `Alfie/AlfieKit/Sources/Core/Services/BFFService/Interceptors/RetryAfterParser.swift`

No `DateProvider`, no `Clock`, no `now:` closure, no `Date.now` anywhere. `UUID()` is constructed
inline in ~23 places, but all of them are identity-only (Apollo interceptor IDs, a Braze user ID, a
list-item ID) or fixture defaults that tests override with literals like `"line-1"`. Time-dependent
*scheduling* is injected, via `AnySchedulerOf<DispatchQueue>`, not via a clock. No randomness
abstraction exists. **This is a latent risk, not a live defect** — state the rule so the next
time-dependent feature does not bake `Date()` into a ViewModel.

## 7. What not to test

**Private methods.** marcin-bo: "Private methods are an implementation detail and never exist in
isolation… You can validate private methods by unit testing public methods"
([Best Practices §Test Only Public Methods](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Best%20Practices%20in%20Swift.md)).
Author opinion, widely held. Note it sits in tension with `@testable import`, which this repo uses
everywhere — though `@testable` raises `internal` to visible, not `private`, so it does not actually
license testing private methods.

**Logic in tests.** "Avoid implementing complex logic within them… identify the presence of logic by
assessing your use of constructs like `if`, `while`, `for`, `switch`… be cautious with operators such
as `do-catch`" (*ibid.*). The skill converges from a different direction: an `if`/`switch` inside a
parameterized test body "mirrors implementation logic. Tests that branch the same way as production
code verify themselves rather than the behavior independently"
([`references/parameterized-testing.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/parameterized-testing.md)).
Two independent sources, same conclusion — the strongest non-Apple consensus in this research.

⚠️ **The repo does not fully hold this line, and the exceptions are defensible.** Two patterns:

- **Table-driven `for` loops.** `Tests/ModelTests/CurrencyFormatterTests.swift` iterates
  `[(code: String, digits: Int)]` tuples with a custom failure message per row. This is "logic in a
  test" by marcin-bo's definition, and it is exactly the case Apple's parameterized-testing doc is
  about: with a loop "it may be unclear which value failed"
  ([ParameterizedTesting.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md)).
  The repo mitigates with interpolated failure messages, which is the best XCTest can do.
- **`do/catch` + `XCTFail` for error paths.** `XCTAssertThrowsError` is used exactly **once** in 911
  tests; the house idiom is a `do { … XCTFail(…) } catch is BFFRequestError { } catch { XCTFail(…) }`,
  as in `Tests/BFFIntegrationTests/ProductDetailsIntegrationTests.swift`. marcin-bo argues against
  this ("adds branching logic to the test which is not desired") and prefers `XCTAssertThrowsError`
  ([Patterns](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Patterns%20in%20Swift.md)).
  The repo's version does buy something real: a typed `catch` pattern that `XCTAssertThrowsError`'s
  `Error`-typed closure cannot express as cleanly. Swift Testing solves it properly with
  `#expect(throws: BFFRequestError.self) { … }`. **Judgement: leave as-is on XCTest; do not write a
  rule that 911 tests violate.**

**Snapshot tests are for layout, not content.** marcin-bo: "Use snapshot tests for testing **visual
layout**. Use low-level unit tests for testing *the content*"
([Best Practices §Use Proper Testing Strategies for UI Testing](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Best%20Practices%20in%20Swift.md)).
Author opinion, but `Docs/SnapshotTesting.md` has already proved it locally: at `precision: 0.9`,
removing `LoadingSpinner` from `SplashView` still passed the snapshot test.

## 8. Coverage is a signal, not a target

van der Lee is clearest: **"100% code coverage should not be your target"** — reaching it is
time-consuming with diminishing returns, and full coverage "can be misleading — it measures code
execution, not scenario comprehensiveness." He gives no percentage and says to prioritise critical
business logic ([avanderlee](https://www.avanderlee.com/swift/unit-tests-best-practices/)). Neither
marcin-bo nor the Swift Testing skill sets a number, and Apple sets none. **No source in this research
proposes a coverage threshold.** Any number a `CODING-STANDARD.md` picked would be invented.

**Repo:** already aligned, and unusually honest about the limits of its own data.
`Alfie/Alfie/Alfie.xctestplan` sets `{"codeCoverage": true}` for the local loop; CI overrides it off
(`SCAN_CODE_COVERAGE=false`) because nothing consumes it there. `Docs/Testing.md` records two
measurement gaps — `AlfieIntegration.xctestplan` collects nothing, and a snapshot-skipped run makes
SwiftUI `body` read as uncovered — and stamps the bundle with the commit it describes. That is the
right relationship with the number.

## 9. Swift Testing vs XCTest

**Availability (precise).** Swift Testing "is included with the Swift 6 toolchain and Xcode 16. You do
not need to add it as a package dependency"
([swift-testing README](https://github.com/swiftlang/swift-testing/blob/main/README.md)). It is
distributed "In Apple's Xcode IDE, versions 16.0 and later, as a framework" and in the Command Line
Tools for Xcode 16.0 and later
([Distributions.md](https://github.com/swiftlang/swift-testing/blob/main/Documentation/Distributions.md)).
It "works on all Apple operating systems which support Swift Concurrency, as well as on Linux and
Windows" ([WWDC24 *Meet Swift Testing*](https://developer.apple.com/videos/play/wwdc2024/10179/)).

**What stays on XCTest (verbatim, Apple):**

> "Please continue using XCTest for any tests which use UI automation APIs like `XCUIApplication` or
> use performance testing APIs like `XCTMetric` as these are not supported in Swift Testing. You must
> also use XCTest for any tests which can only be written in Objective-C."
> — [WWDC24 *Meet Swift Testing*](https://developer.apple.com/videos/play/wwdc2024/10179/)

The skill states the same three exclusions
([`SKILL.md` rule 1](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/SKILL.md)) —
verified against the primary. This repo has an `AlfieUITests` target (5 files, 4 test functions),
which would stay on XCTest regardless.

**Coexistence.** "A single source file can contain tests written with XCTest as well as other tests
written with the testing library." Since the Swift 6.4 toolchain there is also a documented
**interoperability** feature with four modes (`none` / `limited` / `complete` / `strict`, selected via
`SWIFT_TESTING_XCTEST_INTEROP_MODE`), letting an `XCTAssert` failure inside a `@Test` register as a
real failure and vice versa; the default depends on toolchain and declared `swift-tools-version`
([MigratingFromXCTest.md §Use interoperability](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md)).
This materially de-risks incremental migration — shared assertion helpers keep working across the
boundary.

**Assertion mapping** (excerpt from Apple's own table, *ibid.*):

| XCTest | Swift Testing |
|---|---|
| `XCTAssertEqual(x, y)` | `#expect(x == y)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `try XCTUnwrap(x)` | `try #require(x)` |
| `XCTAssertThrowsError(try f())` | `#expect(throws: (any Error).self) { try f() }` |
| `XCTAssertNoThrow(try f())` | `#expect(throws: Never.self) { try f() }` |
| `XCTFail("…")` | `Issue.record("…")` |
| `continueAfterFailure = false` | `try #require(…)` at the prerequisite |
| `XCTSkipIf` / `XCTSkipUnless` | `.disabled(if:)` / `.enabled(if:)` traits |
| `throw XCTSkip` mid-test | `try Test.cancel("…")` |
| `XCTExpectFailure` | `withKnownIssue { … }` |
| `setUp` / `tearDown` | `init()` / `deinit` |
| `XCTestExpectation` + `fulfillment(of:)` | `await confirmation { … }` |
| `XCTAssertEqual(_:_:accuracy:)` | **no equivalent** — use `isApproximatelyEqual()` from [swift-numerics](https://github.com/apple/swift-numerics) |

That last row is a real migration cost for numeric tests, and is stated by Apple, not inferred.

**Repo:** 100% XCTest. 97 files `import XCTest` (91 in `AlfieKit/Tests`, plus `AlfieTests`,
`AlfieUITests`, `TestUtils`, `Mocks`); 84 `final class …: XCTestCase`. **Zero** `import Testing`, and
zero occurrences of `@Test`, `#expect`, `#require`, `@Suite`, `confirmation`, `withKnownIssue`,
`.serialized` or Swift Testing `Tag`. `Package.swift` declares `// swift-tools-version: 5.9`,
`platforms: [.iOS(.v16)]`, no `swiftLanguageMode`, no `StrictConcurrency`, no upcoming-feature flags —
so Swift 5 language mode throughout (the app target is `SWIFT_VERSION = 5.0`).

**Migration blockers specific to this repo, in order of severity:**

1. **Every shared helper is an `XCTestCase` extension.** `XCTAssertEmitsValue` and friends
   (129 + 11 + 8 call sites), `trackForMemoryLeak`, and the named `.default` / `.inverted` timeouts all
   hang off `XCTestCase`. A Swift Testing test is not an `XCTestCase`, so none of them are reachable.
   `TestUtils` must be ported first, or half the suite loses its idiom.
2. **`swift-tools-version: 5.9`.**
   > ⚠️ **Unverified.** I could not confirm from a primary source whether SwiftPM enables Swift Testing
   > for a package declaring tools-version 5.9. Apple documents availability in terms of the *toolchain
   > and Xcode version*, not the tools version, and states no minimum `swift-tools-version`. Community
   > discussion on the Swift Forums suggests 6.0 may be required for `swift test`, but I found no
   > authoritative statement. **Spike this before any adoption discussion** — it may turn "write new
   > tests in Swift Testing" into a tools-version bump with its own concurrency-checking fallout.
3. **`XCTAssertEqual(_:_:accuracy:)` has no equivalent** (Apple, above). `CurrencyFormatterTests` and
   the price/total tests are the exposure.
4. **Swift 5 language mode.** Swift Testing runs tests on arbitrary tasks and leans on `Sendable`;
   moving to it without strict concurrency checking invites data-race warnings appearing all at once.

## 10. Parameterized tests

Apple's argument is about **diagnostics**, not brevity: with a `for` loop inside one test "it may be
unclear which value failed", whereas each argument becomes its own test *case* with its own
diagnostics, individually re-runnable
([ParameterizedTesting.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md)).
Cases of a parameterized function "run in parallel with each other" by default (*ibid.*), and Apple
warns that "very large ranges such as `0 ..< .max` may take an excessive amount of time to test, or
may never complete" (*ibid.*).

The skill adds four pitfalls Apple does **not** document — treat as the author's experience, not
framework behaviour
([`references/parameterized-testing.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/parameterized-testing.md)):

1. `zip` **silently truncates** to the shorter collection — missing coverage with no error. Prefer an
   array of tuples or a dictionary so pairs cannot misalign.
2. `zip(A.allCases, B.allCases)` breaks silently if either enum is reordered.
3. **Derived expected values mask bugs**: `#expect(format(day) == day.rawValue)` passes even when both
   sides share the same casing bug. Use concrete literals.
4. `allCases` suits *property-based* assertions (a law that holds for every case), not example-based
   mappings.

Points 1 and 3 apply verbatim to XCTest table-driven loops too, and are worth carrying into the
standard regardless of framework.

**Repo:** no parameterized-test facility — XCTest has none. The closest analogue is the tuple-table
`for` loop in `Tests/ModelTests/CurrencyFormatterTests.swift`, which is precisely the case
parameterization exists to improve. This is a genuine capability the repo does not have.

## 11. Snapshot testing

marcin-bo's layout-vs-content split is in §7. The mechanics are already documented in
`Docs/SnapshotTesting.md` and do not need re-deriving:
[swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) 1.18.3, references
committed under `__Snapshots__/`, `precision: 1.0` / `perceptualPrecision: 0.95` as the suite default,
an exact iOS-minor pin, and a `verify.sh` grep guard that fails the run if any test is committed in
record mode (`SNAPSHOT_ALLOW_RECORD=1` lifts it for a deliberate record run).

**Repo:** 31 reference PNGs across 6 snapshot classes (`ProductDetailsTests` 10, `BagTests` 8,
`ProductListingTests` 6, `AppFeatureTests` 5, `HomeTests` 2). The idiom is uniform: no `setUp`, a local
`let sut = View(viewModel: MockXViewModel(state: .success(.fixture(…))))`, then a single
`assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)` with a
per-class `private let isRecording = false`. Views are always driven by **Mock ViewModels holding a
literal `ViewState`**, never by real ViewModels — the cleanest possible separation of layout test from
logic test. Remote image URLs are deliberately avoided because `RemoteImage` is non-deterministic at
`precision: 1.0`. `Docs/SnapshotTesting.md` also records the empirical finding that any slack big
enough to hide an animation's motion is big enough to hide a whole small element — stronger evidence
for "snapshot layout, unit-test content" than either external source offers.

## 12. Test performance and parallelization

**XCTest parallelizes at target and class granularity**, not per test method:

> "In addition, you can enable Xcode to run tests in parallel on a target and test object class
> level… If the server has enough cores available, multiple targets and test object classes can be
> executed concurrently." — [WWDC22 110361](https://developer.apple.com/videos/play/wwdc2022/110361/)

**Swift Testing parallelizes at the test-function level, by default, in-process:**

> "By default, tests run in parallel with respect to each other. Parallelization is accomplished by
> the testing library using task groups, and tests generally all run in the same process. The number
> of tests that run concurrently is controlled by the Swift runtime."
> — [Parallelization.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Parallelization.md)

`.serialized` is recursive down a suite, has **no effect** on a non-parameterized test function, and
"doesn't affect the execution of a test relative to its peers or to unrelated tests" (*ibid.*).

> ⚠️ **Claim I could not verify.** The skill states Swift Testing's "execution order is randomized to
> expose hidden test dependencies"
> ([`references/parallelization-and-isolation.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/parallelization-and-isolation.md)).
> `Parallelization.md` documents parallelism but says nothing about randomization, and I found no
> mention of randomized ordering in the swift-testing repo's documentation or environment-variable
> reference. Xcode *test plans* do offer a randomized execution order option for XCTest, which may be
> the origin of the claim. Safe formulation: **order is not guaranteed; do not depend on it** — the
> actionable rule either way.

**Repo:** parallelization is configured in two places that do not agree.
`Alfie/Alfie.xcodeproj/xcshareddata/xcschemes/Alfie.xcscheme` sets `parallelizable = "YES"` on the
`AlfieTests` and `AlfieUITests` testable references. But the AlfieKit SPM test targets — which are
where 911 of the 923 tests live — arrive via the test plans, and neither plan sets `parallelizable`.
`Alfie/Alfie/Alfie.xctestplan` contains only `{"codeCoverage": true}` and lists 18 targets;
`AlfieIntegration.xctestplan` sets only `ALFIE_BFF_BASE_URL`. Neither sets a test timeout or an
execution-order option, so Apple's 600s default applies.

Given the suite is already written to be independent (fresh SUT per test, no globals, no order
dependence found), opting the AlfieKit targets into parallel execution is a low-risk speed win worth
measuring — with the caveat that the 6 snapshot classes share one pinned simulator.

## 13. CI

Apple's CI-relevant levers are the test plan's execution time allowance (default 600s) and repetition
policies ([WWDC22 110361](https://developer.apple.com/videos/play/wwdc2022/110361/)). Apple is
explicit that `retry-on-failure` is for "tests that rely on an unreliable external service", not a
blanket flake suppressant, and that "unnecessary repetitions are wasteful."

The skill's CI advice is about filtering: use **tags** for test-plan include/exclude rather than
name-based filters, and `.disabled("reason")` with a `.bug(...)` link instead of commenting tests out
([`references/traits-and-tags.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/traits-and-tags.md)).
Tags are Swift Testing only, so this is inapplicable here today.

**Repo:** `.github/workflows/alfie.yml` runs one `unit-tests` job on `macos-26`, 30-minute timeout,
with `concurrency: cancel-in-progress`, caching Homebrew/gems/SPM/DerivedData, and a single test step:
`bundle exec fastlane ios test --env default`. `fastlane/Fastfile`'s `test` lane is one line,
`scan(ensure_devices_found: true)`, configured entirely from `fastlane/.env.default`
(`SCAN_TESTPLAN=Alfie`, so **CI runs unit tests only — no integration, no UI tests**;
`SCAN_DEVICE=iPhone 17 Pro (26.4)`; `SCAN_CODE_COVERAGE=false`; `SCAN_RESULT_BUNDLE=true`). The
`.xcresult` and JUnit artefacts upload on failure only, 7-day retention.

**There are no test retries anywhere** — no `number_of_retries`, no `--retry-tests-on-failure`, no
`-test-iterations`. Given Apple's own framing (retries are for unreliable *external* services, and the
CI plan deliberately excludes the integration target), that is the correct default and worth stating
so nobody adds a blanket retry to paper over a flake.

Skips are confined to `BFFIntegrationTests`: all 11 `XCTSkip` uses are environment gates —
`IntegrationTestCase.swift` POSTs `{"query":"{__typename}"}` as a readiness probe and skips the whole
class if the BFF is not answering, and four files `XCTSkipUnless` on thin seed data. **No unit test is
skipped or commented out.** The exceptions are cosmetic: the `UtilsTests` placeholder
(`XCTAssertTrue(true)`) and three commented-out properties in `DeepLinkHandlerTests` left over from a
removed coordinator.

## 14. Test code is production code

van der Lee: **"Your test code is just as important as your application code"** — reuse code, use
protocols, define reusable properties, clean up properly
([avanderlee](https://www.avanderlee.com/swift/unit-tests-best-practices/)). marcin-bo's helper-method
and property sections are the concrete form of the same rule.

One mechanic is worth carrying over verbatim because it is easy to get wrong: assertions inside helper
methods must forward source location, or every failure points at the helper.

```swift
private func helperExpect(_ param: Bool, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(param, file: file, line: line)
}
```
— [marcin-bo, Patterns §How To Handle `XCTAssert*` in Helper Methods](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Patterns%20in%20Swift.md).
Swift Testing's equivalent parameter is `sourceLocation:` on `#expect` / `#require`
([Expectations.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Expectations.md)).

marcin-bo also documents a **memory-leak assertion** built on `addTeardownBlock` with a weak capture
(Patterns §How To Detect Memory Leaks in Unit Tests).

**Repo:** the memory-leak helper already exists, essentially identical to marcin-bo's, at
`Alfie/AlfieKit/Sources/TestUtils/Helpers/XCTestCase+MemoryLeak.swift` — and is used **5 times across
3 files** (`CoreTests/ServiceTests/WishlistServiceTests.swift`,
`CoreTests/ServiceTests/UserDefaultsStoreTests.swift`, `WishlistTests/WishlistTests.swift`). It is
effectively vestigial. It forwards `#filePath`/`#line` correctly; the far more heavily used Combine
helpers in `XCTestCase+Combine.swift` do **not**, so every `XCTAssertEmitsValue` failure — 148 call
sites — reports against `TestUtils` rather than the test that failed. That is the highest-value,
lowest-cost fix in this document.

⚠️ **Counter-evidence in the repo:** `Alfie/.swiftlint.yml` excludes `AlfieKit/Tests` and
`AlfieKit/Sources/Mocks` from linting entirely. Test code is explicitly held to a *lower* mechanical
bar than production code here — the direct opposite of the van der Lee rule. Whether that is worth
changing is a real cost/benefit call (lint noise across 911 tests), but the standard should say which
way it has decided rather than leave it implicit.

---

# Contradictions & judgement calls

### 1. Generated mocks vs hand-written mocks

- **marcin-bo:** "Automate Mocks Generation" with [Sourcery](https://github.com/krzysztofzablocki/Sourcery)
  `AutoMockable` — call counts, received parameters, invocation lists and closures for free
  ([Best Practices](https://github.com/marcin-bo/Unit-Testing-In-Swift/blob/main/Unit%20Testing%20Best%20Practices%20in%20Swift.md)).
- **Swift Testing skill:** hand-written in-memory fakes
  ([`references/performance-and-best-practices.md` §4](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/performance-and-best-practices.md)).
- **van der Lee:** silent. **Apple:** silent. No primary source exists.

**Judgement: keep hand-written mocks.** The repo's 30 closure-stub mocks are readable, double as
`#Preview` fixtures (so they must live in a production target, where generated test scaffolding would
be awkward), and adding Sourcery would introduce a third code-generation step alongside
`run-apollo-codegen.sh` and `generate-design-tokens.sh` — after which `CLAUDE.md`'s "never hand-edit
generated code" rule would cover the mocks too, removing the ability to hand-tune behaviours like
"unset closure throws". The one thing Sourcery buys that the repo lacks is call counting, and tests
already get that by capturing into a local array inside the `on<Method>Called` closure, as
`BagViewModelTests` does with `capturedRoutes` and `MockAnalyticsTracker` does with `trackedActions`.

### 2. One assertion per test

- **marcin-bo:** two adjacent sections, "Perform One Act Per Test Method" and "Perform One Assertion
  Per Test Method" — but the second section's body is a verbatim copy of the first's and argues for
  *one act*, not one assertion. The strict one-assert rule is asserted, never argued.
- **Swift Testing skill:** "Keep each test focused on one behavior" — behaviour, not assertion count
  ([`references/fundamentals.md`](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/references/fundamentals.md)).
- **Apple:** `#expect` deliberately *continues* after failure so you see all failures in one run; only
  `#require` stops
  ([Expectations.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Expectations.md)).
  That design point argues against one-assert-per-test.

**Judgement: mandate one *act*, not one assertion.** `BagViewModelTests` asserting both `lines` and
`totalQuantity` after a single `viewDidAppear()` is correct, not a smell.

### 3. Coverage target

All three sources decline to name a number; van der Lee explicitly rejects 100%. **Judgement: name no
number.** The repo's existing stance in `Docs/Testing.md` — coverage as a diagnostic, with its
measurement gaps documented and the bundle stamped with the commit it describes — is better than a
threshold and should be the standard.

### 4. Swift Testing adoption

- **Skill:** "Prefer Swift Testing for Swift unit and integration tests"
  ([`SKILL.md` rule 1](https://github.com/AvdLee/Swift-Testing-Agent-Skill/blob/main/swift-testing-expert/SKILL.md)).
- **marcin-bo and van der Lee:** XCTest throughout; van der Lee mentions Swift Testing only as a
  pointer to a separate article.
- **Apple:** encourages migration but documents coexistence and incrementalism explicitly, and keeps
  UI / performance / Objective-C on XCTest
  ([MigratingFromXCTest.md](https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md),
  [WWDC24](https://developer.apple.com/videos/play/wwdc2024/10179/)).

**Judgement: do not adopt piecemeal.** A standard saying "prefer Swift Testing for new tests" would,
in this repo, immediately produce a suite where the new half cannot use `XCTAssertEmitsValue`,
`XCTAssertNoEmit`, `trackForMemoryLeak` or the named timeout constants at all — every shared helper in
`TestUtils` is an `XCTestCase` extension (§9). Swift 6.4's interop modes soften but do not remove
that. The honest options are (a) stay on XCTest and write the standard against it, or (b) fund a
migration that ports `TestUtils` first and answers the tools-version question. Option (a) is what the
TL;DR above assumes.

### 5. AAA comments

marcin-bo mandates the labelled three-phase structure; the skill and Apple do not mention it. The repo
achieves the separation without labels and spends its comment budget on *why*, often citing acceptance
criteria. **Judgement: require the structure, not the comments.**

### 6. "Avoid logic in tests" vs the repo's table-driven loops and `do/catch`

marcin-bo and the skill both say no branching in tests (§7). The repo does both — tuple-table `for`
loops in `CurrencyFormatterTests`, and `do/catch` + `XCTFail` as the near-universal error-path idiom
(`XCTAssertThrowsError` appears once in 911 tests). Both are reasonable *given XCTest's limits*: the
loop compensates with per-row interpolated failure messages, and the typed `catch` expresses something
`XCTAssertThrowsError`'s `Error`-typed closure cannot. **Judgement: state the rule as "no branching
that mirrors the implementation's own branching", which is the part that actually causes
self-verifying tests, and leave table loops and typed `catch` alone.** Both are things Swift Testing
would fix properly (`@Test(arguments:)`, `#expect(throws: E.self)`) — note them as migration benefits
rather than present-day violations.

### 7. "Avoid magic strings"

marcin-bo's example replaces `"g122345j"` with `let INVALID_NUMBER = "g122345j"` — a SCREAMING_SNAKE
local that violates the repo's own SwiftLint identifier rules (`Docs/CodeStyle.md`: identifiers start
lowercase). The intent (name the significant input) is sound; the style is not importable.
**Judgement: adopt the intent, drop the naming convention.**

---

# Repo gap analysis

| Rule | Repo status | Migration cost |
|---|---|---|
| Descriptive `test_…` naming convention | **Already** (912/919) — but undocumented | None to document; ~7 camelCase stragglers to rename |
| One act per test | **Already** in every file sampled | None |
| No branching that mirrors the implementation | **Partial** — table `for` loops in `ModelTests`, `do/catch` error idiom (911 tests) | None if scoped as in Contradictions §6; high if written as a blanket ban |
| No sleeps in tests | **Already** — zero `Task.sleep` / `Thread.sleep` / test-side `asyncAfter` | None |
| Deterministic concurrency via an `actor` gate | **Partial** — `FetchGate` in `ProductListingViewModelTests`, a sibling in `CartServiceTests`; not documented | Low; document the existing pattern |
| Fresh SUT per test; teardown nils every reference | **Already** — 36 setUp / 33 tearDown / 56 `sut`, idiom strictly consistent | None |
| `makeSUT`-style factory helpers | **Partial** — 18 `make…` helpers, ad hoc shape | Low; codify |
| Protocol collaborators injected via feature `DependencyContainer` | **Already** — architectural invariant (`Docs/Architecture.md`); tests construct containers from mocks rather than bypassing them | None |
| Hand-written `Mock<Service>` with `on<Method>Called` closure stubs | **Already** — 30 mocks, uniform idiom | None |
| Unset mock closure throws rather than silently succeeding | **Already** — deliberate, with rationale comments | None; write it down |
| `.fixture(...)` builders for domain values | **Already** — 10 fixture files, all params defaulted | None |
| Specialised assertions (`XCTAssertEqual` over `XCTAssert`) | **Already** — 930 `XCTAssertEqual`, zero bare `XCTAssert(` | None |
| `try XCTUnwrap` over force-unwrap | **Already** — 90 uses | None |
| `accuracy:` for floating-point comparison | **Unknown** — not audited | Low |
| Full state matrix (loading / success / empty / error) | **Partial** — `BagViewModelTests` and the snapshot suite cover it; not a stated rule, and `Docs/SnapshotTesting.md` deliberately leaves mid-rollout screens uncovered | Low to state; per-screen work to close |
| Test-before-bugfix | **Unknown** — no policy recorded anywhere | None to state; cultural |
| No coverage threshold; coverage as a diagnostic | **Already** — `Docs/Testing.md` documents the gaps; CI has coverage off | None |
| Memory-leak tracking on SUT and doubles | **Partial** — helper exists, used 5 times in 3 of 91 files | Low per test; ~88 files to backfill if made mandatory. Consider narrowing the rule to services and long-lived objects |
| `#filePath` / `#line` forwarding in assertion helpers | **Partial** — correct in `XCTestCase+MemoryLeak.swift`, **missing** in `XCTestCase+Combine.swift` | Low — add `file:` / `line:` to ~7 helpers; 148 call sites immediately report against the right line |
| Injected `Date` / clock | **Partial** — the single `Date()` is a default-param seam; no general abstraction | None today; a `Clock` seam is only needed when time-dependent logic lands |
| Injected `UUID` | **No** — ~23 inline `UUID()`, all identity-only or fixture defaults | Low-medium if ever needed; nothing depends on predictable IDs today |
| Injected scheduler for time-driven Combine | **Partial** — `AnySchedulerOf` seam only in `ProductDetailsDependencyContainer`; `TestScheduler` used in one test file | Low per container |
| Locale / time-zone pinning | **No** — not set anywhere | Low; set on the simulator in `test-for-verification.sh` |
| Test code linted like production code | **No** — `.swiftlint.yml` excludes `AlfieKit/Tests` and `Sources/Mocks` | Medium — one lint run over 911 tests, then fix the fallout. Decide deliberately either way |
| Snapshot = layout, unit test = content | **Already** — snapshot views always driven by Mock ViewModels holding a literal `ViewState`; empirically justified in `Docs/SnapshotTesting.md` | None |
| Every test target in `Alfie.xctestplan` | **Already** — 18 targets; the silent-skip failure mode is documented | None |
| No disabled or placeholder tests | **Partial** — all 11 `XCTSkip` are legitimate env gates in `BFFIntegrationTests`; but `UtilsTests` is an `XCTAssertTrue(true)` placeholder and `DeepLinkHandlerTests` carries 3 commented-out properties | Trivial cleanup |
| Parallel test execution | **No** for AlfieKit — scheme sets `parallelizable = "YES"` only on `AlfieTests` / `AlfieUITests`; neither test plan sets it, and 911 of 923 tests arrive via the plans | Low to try (suite is already independent); must verify the 6 snapshot classes against the pinned simulator |
| Test timeout / execution time allowance in the plan | **No** — unset, so Apple's 600s default applies | Trivial |
| No blanket CI retries | **Already** — zero retry configuration; CI plan excludes the integration target | None; write it down so nobody adds one |
| Parameterized tests | **No** — XCTest has no equivalent; table `for` loops are the workaround | Blocked on Swift Testing adoption |
| Traits / tags for CI filtering | **No** — Swift Testing only | Blocked on Swift Testing adoption |
| `withKnownIssue` for temporary known failures | **No** — Swift Testing only; XCTest's `XCTExpectFailure` is unused | Low if wanted on XCTest today |
| Swift Testing (`@Test` / `#expect`) | **No** — 0 of 97 files | **High.** Four blockers in §9: every `TestUtils` helper is an `XCTestCase` extension; `swift-tools-version: 5.9` is unverified; `XCTAssertEqual(_:_:accuracy:)` has no equivalent; Swift 5 language mode with no strict-concurrency opt-in. Not a per-PR decision |

---

## Open questions worth a spike

1. **Does `swift-tools-version: 5.9` block Swift Testing?** Unresolved against primary sources (§9).
   Answer before any adoption discussion.
2. **Source-location forwarding in `XCTestCase+Combine.swift`.** ~7 helpers, 148 call sites. The
   highest value-per-hour item in this document.
3. **Does enabling `parallelizable` on the AlfieKit test targets break the snapshot suite?** The 6
   snapshot classes share one pinned simulator; the other 78 classes look parallel-safe.
4. **Should `AlfieKit/Tests` be linted?** Currently excluded. The single clearest divergence between
   the repo and the "test code is production code" rule that all sources endorse.
5. **Pin locale and time zone** in `test-for-verification.sh` — the one item from Apple's flakiness
   table (WWDC22) the repo does not cover.
